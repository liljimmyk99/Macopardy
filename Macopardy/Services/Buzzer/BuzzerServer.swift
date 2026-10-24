//
//  BuzzerServer.swift
//  Macopardy
//
//  Embedded HTTP + WebSocket server powered by Network.framework.
//
//  Responsibilities
//  ─────────────────
//  • Listens on BuzzerConstants.port for incoming TCP connections
//  • Serves buzzer.html (bundled resource) for plain HTTP GET / requests
//  • Handles WebSocket connections (manual RFC 6455 framing over plain TCP)
//  • Validates the join code on first contact; rejects wrong codes
//  • Pings all sessions on a timer; evicts sessions that miss the TTL
//  • Broadcasts ServerMessage values to all authenticated sessions
//  • Reports the connected-client count via an AsyncStream
//

import CommonCrypto
import Foundation
import Network
import OSLog

// MARK: - BuzzerServer

actor BuzzerServer {

    private enum ServerError: Error {
        case invalidPort
    }

    // MARK: - Public State

    /// The join code that phones must present to authenticate.
    nonisolated let joinCode: String

    // MARK: - Private State

    private var listener: NWListener?
    private var sessions: [UUID: ClientSession] = [:]
    private var heartbeatTask: Task<Void, Never>?

    /// Teams phones can pick from, as last pushed by the app. `claimed` is
    /// ignored here; it is always derived from `claims`.
    private var currentTeams: [BuzzerTeam] = []
    private var claims = TeamClaimRegistry()
    private var scores: [UUID: Int] = [:]
    private var engine = BuzzerEngine()
    private var tieWindowTask: Task<Void, Never>?
    private var codeLimiter = AttemptRateLimiter(
        maxAttempts: BuzzerConstants.maxCodeAttempts,
        window: BuzzerConstants.codeAttemptWindow,
        lockout: BuzzerConstants.rateLimitLockout
    )
    private var claimLimiter = AttemptRateLimiter(
        maxAttempts: BuzzerConstants.maxClaimAttempts,
        window: BuzzerConstants.claimAttemptWindow,
        lockout: BuzzerConstants.rateLimitLockout
    )

    /// The HTML payload loaded once from the bundle and cached.
    private let buzzerHTML: Data

    // MARK: - Claimed-teams stream

    /// Emits the set of team ids currently held by a phone whenever it changes.
    private var claimedContinuation: AsyncStream<Set<UUID>>.Continuation?
    nonisolated let claimedTeamsStream: AsyncStream<Set<UUID>>

    // MARK: - First-buzz stream

    /// Emits the team that is answering after a buzz, or nil when none is.
    private var firstBuzzContinuation: AsyncStream<UUID?>.Continuation?
    nonisolated let firstBuzzStream: AsyncStream<UUID?>

    // MARK: - Connection-count stream

    private var countContinuation: AsyncStream<Int>.Continuation?
    nonisolated let connectedCountStream: AsyncStream<Int>

    // MARK: - Listener-failure stream

    /// Emits a description if the listener fails after it started successfully.
    private var failureContinuation: AsyncStream<String>.Continuation?
    nonisolated let listenerFailureStream: AsyncStream<String>

    // MARK: - Init

    init(joinCode: String) {
        self.joinCode = joinCode

        // Load the bundled web page once at init time.
        let bundledPageURL = Bundle.main.url(
            forResource: "buzzer",
            withExtension: "html",
            subdirectory: "Buzzer"
        ) ?? Bundle.main.url(forResource: "buzzer", withExtension: "html")

        if let url = bundledPageURL,
           let data = try? Data(contentsOf: url) {
            self.buzzerHTML = data
        } else {
            AppLogger.buzzer.error("buzzer.html not found in bundle — clients will receive a 404")
            self.buzzerHTML = Data("<h1>Buzzer page not found</h1>".utf8)
        }

        // Wire up the count stream before `self` is fully initialised.
        var continuation: AsyncStream<Int>.Continuation!
        self.connectedCountStream = AsyncStream { continuation = $0 }
        self.countContinuation = continuation

        var claimedCont: AsyncStream<Set<UUID>>.Continuation!
        self.claimedTeamsStream = AsyncStream { claimedCont = $0 }
        self.claimedContinuation = claimedCont

        var firstBuzzCont: AsyncStream<UUID?>.Continuation!
        self.firstBuzzStream = AsyncStream { firstBuzzCont = $0 }
        self.firstBuzzContinuation = firstBuzzCont

        var failureCont: AsyncStream<String>.Continuation!
        self.listenerFailureStream = AsyncStream { failureCont = $0 }
        self.failureContinuation = failureCont
    }

    // MARK: - Lifecycle

    /// Starts the listener and waits until it is ready. Throws if the port is
    /// already in use or the listener otherwise fails to start.
    func start() async throws {
        let tcpParams = NWParameters.tcp
        tcpParams.allowLocalEndpointReuse = true

        guard let port = NWEndpoint.Port(rawValue: BuzzerConstants.port) else {
            throw ServerError.invalidPort
        }

        let listener = try NWListener(using: tcpParams, on: port)
        self.listener = listener

        listener.newConnectionHandler = { [weak self] connection in
            guard let self else { return }
            Task { await self.handleNewConnection(connection) }
        }

        let portNumber = BuzzerConstants.port
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                // The handler can fire many times; resume the continuation only once.
                let resumed = OSAllocatedUnfairLock(initialState: false)
                listener.stateUpdateHandler = { [weak self] state in
                    switch state {
                    case .ready:
                        AppLogger.buzzer.info("BuzzerServer listening on port \(portNumber)")
                        if resumed.withLock({ let was = $0; $0 = true; return !was }) {
                            continuation.resume()
                        }
                    case .failed(let error):
                        AppLogger.buzzer.error("BuzzerServer listener failed: \(error)")
                        if resumed.withLock({ let was = $0; $0 = true; return !was }) {
                            continuation.resume(throwing: error)
                        } else {
                            Task { await self?.reportListenerFailure(error) }
                        }
                    default:
                        break
                    }
                }
                listener.start(queue: .global(qos: .utility))
            }
        } catch {
            listener.cancel()
            self.listener = nil
            throw error
        }

        startHeartbeat()
    }

    private func reportListenerFailure(_ error: Error) {
        failureContinuation?.yield(error.localizedDescription)
    }

    /// Stops the server, cancels all sessions, and cleans up the heartbeat timer.
    func stop() {
        heartbeatTask?.cancel()
        heartbeatTask = nil
        tieWindowTask?.cancel()
        tieWindowTask = nil
        sessions.values.forEach { $0.close() }
        sessions.removeAll()
        claims = TeamClaimRegistry()
        listener?.cancel()
        listener = nil
        countContinuation?.finish()
        claimedContinuation?.finish()
        firstBuzzContinuation?.finish()
        failureContinuation?.finish()
        AppLogger.buzzer.info("BuzzerServer stopped")
    }

    // MARK: - Broadcasting

    /// Sends a message to every authenticated session.
    func broadcast(_ message: ServerMessage) {
        for session in sessions.values where session.isAuthenticated {
            session.send(message)
        }
    }

    // MARK: - Teams & claims

    /// Replaces the team list phones pick from. Claims on teams that no longer
    /// exist are dropped. Does nothing if the visible fields did not change.
    func updateTeams(_ teams: [BuzzerTeam]) {
        let normalized = teams.map {
            BuzzerTeam(id: $0.id, name: $0.name, color: $0.color, claimed: false)
        }
        guard normalized != currentTeams else { return }
        currentTeams = normalized
        claims.prune(validTeamIDs: Set(normalized.map(\.id)))
        claimsChanged()
    }

    /// Frees a team's slot and disconnects its phone, which shows "Removed by
    /// host". The team and its score are untouched, so a new phone can claim it.
    func removePhone(forTeam teamID: UUID) {
        guard let sessionID = claims.remove(teamID: teamID) else { return }
        if let session = sessions.removeValue(forKey: sessionID) {
            session.send(.removed, closeAfterSending: true)
            publishCount()
            AppLogger.buzzer.info("[\(sessionID)] Removed by host from team \(teamID)")
        }
        claimsChanged()
    }

    // MARK: - Buzzer

    /// Latest scores, used to break ties between simultaneous buzzes.
    func updateScores(_ newScores: [UUID: Int]) {
        scores = newScores
    }

    /// Sets up the buzzers for a new screen: clears lockouts and any buzz in progress.
    func setBuzzerMode(_ mode: BuzzerMode) {
        tieWindowTask?.cancel()
        tieWindowTask = nil
        engine.apply(mode)
        buzzerChanged()
    }

    /// The team answered wrong: lock it out and re-arm the others.
    func markWrong(teamID: UUID) {
        engine.markWrong(teamID: teamID, eligibleTeamIDs: claims.claimedTeamIDs)
        buzzerChanged()
    }

    func markCorrect() {
        tieWindowTask?.cancel()
        tieWindowTask = nil
        engine.markCorrect()
        buzzerChanged()
    }

    private func handleBuzz(from session: ClientSession) {
        guard let teamID = claims.teamID(for: session.id) else { return }
        let buzz = Buzz(teamID: teamID, receivedAt: Date(), score: scores[teamID] ?? 0)
        switch engine.buzz(buzz) {
        case .tooEarly:
            session.send(.buzzerState(.tooEarly))
        case .ignored:
            break
        case .windowStarted:
            tieWindowTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(BuzzerConstants.tieWindow))
                guard !Task.isCancelled else { return }
                await self?.closeTieWindow()
            }
            buzzerChanged()
        case .addedToWindow:
            buzzerChanged()
        }
    }

    private func closeTieWindow() {
        tieWindowTask = nil
        if let winner = engine.closeWindow() {
            AppLogger.buzzer.info("Team \(winner.teamID) buzzed in first")
        }
        buzzerChanged()
    }

    /// Pushes each claimed phone its button state and tells the host UI who is answering.
    private func buzzerChanged() {
        for teamID in claims.claimedTeamIDs {
            sendBuzzerState(toTeam: teamID)
        }
        firstBuzzContinuation?.yield(engine.firstBuzzTeamID)
    }

    private func sendBuzzerState(toTeam teamID: UUID) {
        guard let sessionID = claims.sessionID(for: teamID),
              let session = sessions[sessionID] else { return }
        session.send(.buzzerState(engine.phoneState(for: teamID)))
    }

    /// Teams with their current claim flags.
    private func teamsPayload() -> [BuzzerTeam] {
        currentTeams.map {
            BuzzerTeam(id: $0.id, name: $0.name, color: $0.color, claimed: claims.isClaimed($0.id))
        }
    }

    /// Tells every phone and the host UI that claims or teams changed.
    private func claimsChanged() {
        broadcast(.teams(teamsPayload()))
        claimedContinuation?.yield(claims.claimedTeamIDs)
    }

    // MARK: - Connection Handling

    private func handleNewConnection(_ connection: NWConnection) {
        // Accumulate bytes until the full HTTP header block has arrived
        // (i.e. until we see \r\n\r\n) before deciding how to route the
        // connection. A single receive() is not guaranteed to deliver all
        // headers in one chunk, so we loop until the terminator is present.
        connection.start(queue: .global(qos: .utility))
        accumulateHTTPHeaders(connection: connection, buffer: Data())
    }

    private func accumulateHTTPHeaders(connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1,
                           maximumLength: 4096) { [weak self] data, _, _, error in
            guard let self, let chunk = data, !chunk.isEmpty, error == nil else {
                connection.cancel()
                return
            }

            var accumulated = buffer
            accumulated.append(chunk)

            // Keep reading until the header block terminator arrives.
            let terminator = Data("\r\n\r\n".utf8)
            guard accumulated.range(of: terminator) != nil else {
                if accumulated.count > 16_384 {
                    // Safety cap — real HTTP headers are never this large.
                    AppLogger.buzzer.warning("Header block exceeded 16 KB — closing connection")
                    connection.cancel()
                    return
                }
                self.accumulateHTTPHeaders(connection: connection, buffer: accumulated)
                return
            }

            // Header names are case-insensitive and browsers put Upgrade well past
            // the first few hundred bytes, so inspect the whole header block.
            let headers = (String(bytes: accumulated, encoding: .utf8) ?? "").lowercased()
            let requestLine = headers.prefix(while: { $0 != "\r" }).split(separator: " ")
            let isGET = requestLine.first == "get"
            let path = requestLine.count > 1
                ? String(requestLine[1].prefix(while: { $0 != "?" }))
                : ""

            if isGET && path == "/ws" && headers.contains("upgrade: websocket") {
                Task { await self.upgradeToWebSocket(connection: connection, requestData: accumulated) }
            } else if isGET && (path == "/" || path == "/index.html") {
                Task { await self.serveHTTP(connection: connection) }
            } else if isGET {
                Task { await self.serveNotFound(connection: connection) }
            } else {
                AppLogger.buzzer.warning("Unrecognised first bytes — closing connection")
                connection.cancel()
            }
        }
    }

    // MARK: - HTTP page serving

    private func serveHTTP(connection: NWConnection) {
        let body = buzzerHTML
        let header = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: \(body.count)\r\nConnection: close\r\n\r\n"
        var response = Data(header.utf8)
        response.append(body)

        connection.send(content: response, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    private func serveNotFound(connection: NWConnection) {
        let response = "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
        connection.send(content: Data(response.utf8), completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    // MARK: - WebSocket upgrade & session loop

    private func upgradeToWebSocket(connection: NWConnection, requestData: Data) {
        // Perform the WebSocket handshake manually: extract the Sec-WebSocket-Key
        // and respond with the RFC 6455 accept value.
        guard let key = extractWebSocketKey(from: requestData),
              let acceptValue = webSocketAccept(for: key) else {
            AppLogger.buzzer.error("Failed to extract Sec-WebSocket-Key — closing")
            connection.cancel()
            return
        }

        let upgradeResponse = "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: \(acceptValue)\r\n\r\n"

        connection.send(
            content: Data(upgradeResponse.utf8),
            completion: .contentProcessed { [weak self] error in
                guard let self, error == nil else {
                    connection.cancel()
                    return
                }
                Task {
                    let session = ClientSession(connection: connection)
                    // Keep any frame bytes that arrived in the same read as the handshake.
                    if let end = requestData.range(of: Data("\r\n\r\n".utf8)) {
                        session.receiveBuffer = Data(requestData[end.upperBound...])
                    }
                    await self.addSession(session)
                    await self.readWebSocketFrames(from: session)
                }
            }
        )
    }

    private func addSession(_ session: ClientSession) {
        sessions[session.id] = session
        publishCount()
        AppLogger.buzzer.info("[\(session.id)] Client connected (total: \(self.sessions.count))")
    }

    /// Drops a session and frees the team it held, if any.
    private func removeSession(_ session: ClientSession) {
        guard sessions.removeValue(forKey: session.id) != nil else { return }
        publishCount()
        if claims.release(sessionID: session.id) != nil {
            claimsChanged()
        }
        AppLogger.buzzer.info("[\(session.id)] Client removed (total: \(self.sessions.count))")
    }

    /// Reads WebSocket frames in a loop until the connection closes.
    private func readWebSocketFrames(from session: ClientSession) async {
        // Frames that arrived together with the handshake.
        processBuffer(of: session)

        while true {
            let (data, done) = await withCheckedContinuation { continuation in
                session.connection.receive(
                    minimumIncompleteLength: 1,
                    maximumLength: 65536
                ) { data, _, isComplete, error in
                    continuation.resume(returning: (data, isComplete || error != nil))
                }
            }

            if let data, !data.isEmpty {
                session.receiveBuffer.append(data)
                processBuffer(of: session)
            }

            if done || sessions[session.id] == nil {
                if sessions[session.id] != nil {
                    removeSession(session)
                }
                return
            }
        }
    }

    /// Parses every complete frame at the front of the session's buffer.
    private func processBuffer(of session: ClientSession) {
        while sessions[session.id] != nil {
            switch WebSocketFrameParser.parse(session.receiveBuffer) {
            case .incomplete:
                return
            case .invalid:
                AppLogger.buzzer.warning("[\(session.id)] Invalid frame — closing")
                removeSession(session)
                session.close()
                return
            case .frame(let frame, let consumed):
                session.receiveBuffer = Data(session.receiveBuffer.dropFirst(consumed))
                handleWebSocketFrame(frame, from: session)
            }
        }
    }

    /// Dispatches a single parsed WebSocket frame.
    private func handleWebSocketFrame(_ frame: WebSocketFrame, from session: ClientSession) {
        switch frame.opcode {
        case 0x0: // Continuation of a fragmented text message
            guard var fragments = session.fragmentBuffer else { return }
            fragments.append(frame.payload)
            if fragments.count > WebSocketFrameParser.maxPayload {
                session.fragmentBuffer = nil
                removeSession(session)
                session.close()
            } else if frame.fin {
                session.fragmentBuffer = nil
                handleTextPayload(fragments, from: session)
            } else {
                session.fragmentBuffer = fragments
            }

        case 0x1: // Text frame
            if frame.fin {
                handleTextPayload(frame.payload, from: session)
            } else {
                session.fragmentBuffer = frame.payload
            }

        case 0x8: // Connection close
            if sessions[session.id] != nil {
                removeSession(session)
            }
            session.close()

        case 0x9: // Ping — respond with pong (opcode 0xA)
            sendRawFrame(opcode: 0xA, payload: frame.payload, to: session)

        case 0xA: // Pong — update heartbeat timestamp
            session.lastPong = Date()

        default:
            break
        }
    }

    private func handleTextPayload(_ payload: Data, from session: ClientSession) {
        guard let msg = try? JSONDecoder().decode(ClientMessage.self, from: payload) else {
            AppLogger.buzzer.warning("[\(session.id)] Undecodable message — ignoring")
            return
        }
        handleClientMessage(msg, from: session)
    }

    private func handleClientMessage(_ message: ClientMessage, from session: ClientSession) {
        switch message {
        case .join(let code, let version):
            guard version == BuzzerConstants.protocolVersion else {
                session.send(
                    .joinRejected(reason: "Unsupported protocol version"),
                    closeAfterSending: true
                )
                removeSession(session)
                return
            }

            // A blocked address is refused even with the right code, otherwise
            // the lockout would only slow down guessing, not stop it.
            if codeLimiter.isBlocked(session.remoteKey) {
                session.send(
                    .joinRejected(reason: "Too many attempts. Try again shortly."),
                    closeAfterSending: true
                )
                AppLogger.buzzer.warning("[\(session.id)] Rejected — code attempts rate limited")
                removeSession(session)
                return
            }

            if code == joinCode {
                session.isAuthenticated = true
                session.lastPong = Date()
                session.send(.joinAccepted(teams: teamsPayload()))
                publishCount()
                AppLogger.buzzer.info("[\(session.id)] Authenticated with code \(code)")
            } else {
                let limited = codeLimiter.record(session.remoteKey)
                session.send(
                    .joinRejected(reason: limited
                        ? "Too many attempts. Try again shortly."
                        : "Invalid join code"),
                    closeAfterSending: true
                )
                AppLogger.buzzer.warning("[\(session.id)] Rejected — wrong code '\(code)'")
                removeSession(session)
            }

        case .claim(let teamID):
            guard session.isAuthenticated else { return }

            if claimLimiter.record(session.remoteKey) {
                session.send(.claimRejected(reason: .rateLimited))
                return
            }

            switch claims.claim(
                teamID: teamID,
                sessionID: session.id,
                validTeamIDs: Set(currentTeams.map(\.id))
            ) {
            case .claimed:
                session.send(.claimAccepted(teamID: teamID))
                sendBuzzerState(toTeam: teamID)
                claimsChanged()
                AppLogger.buzzer.info("[\(session.id)] Claimed team \(teamID)")
            case .alreadyHeld:
                session.send(.claimAccepted(teamID: teamID))
                sendBuzzerState(toTeam: teamID)
            // Refresh the picker first so the rejection message isn't wiped by it.
            case .taken:
                session.send(.teams(teamsPayload()))
                session.send(.claimRejected(reason: .taken))
            case .invalidTeam:
                session.send(.teams(teamsPayload()))
                session.send(.claimRejected(reason: .invalidTeam))
            }

        case .pong:
            session.lastPong = Date()

        case .buzz:
            guard session.isAuthenticated else { return }
            handleBuzz(from: session)
        }
    }

    // MARK: - Heartbeat

    private func startHeartbeat() {
        let interval = BuzzerConstants.pingInterval
        heartbeatTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { return }
                self.heartbeatTick()
            }
        }
    }

    private func heartbeatTick() {
        let ttl = BuzzerConstants.heartbeatTTL
        let now = Date()
        var toRemove: [ClientSession] = []

        for (id, session) in sessions {
            if !session.isAuthenticated {
                // Never joined: give it one TTL to send a valid `join`, don't ping it.
                if now.timeIntervalSince(session.connectedAt) > ttl {
                    AppLogger.buzzer.info("[\(id)] No join within TTL — disconnecting")
                    session.close()
                    toRemove.append(session)
                }
            } else if now.timeIntervalSince(session.lastPong) > ttl {
                AppLogger.buzzer.info("[\(id)] Heartbeat TTL exceeded — disconnecting")
                session.close()
                toRemove.append(session)
            } else {
                session.send(.ping)
            }
        }

        // Removing a session also frees the team it held.
        toRemove.forEach(removeSession)

        codeLimiter.prune(now: now)
        claimLimiter.prune(now: now)
    }

    // MARK: - Helpers

    private func publishCount() {
        countContinuation?.yield(sessions.filter { $0.value.isAuthenticated }.count)
    }

    /// Builds and sends a minimal unmasked WebSocket frame.
    /// Server-to-client frames are never masked (RFC 6455 §5.1).
    private func sendRawFrame(opcode: UInt8, payload: Data, to session: ClientSession) {
        var frame = Data()
        frame.append(0x80 | (opcode & 0x0F))  // FIN + opcode
        let len = payload.count
        if len < 126 {
            frame.append(UInt8(len))
        } else if len < 65536 {
            frame.append(126)
            frame.append(UInt8(len >> 8))
            frame.append(UInt8(len & 0xFF))
        } else {
            frame.append(127)
            for shift in stride(from: 56, through: 0, by: -8) {
                frame.append(UInt8((len >> shift) & 0xFF))
            }
        }
        frame.append(contentsOf: payload)
        session.connection.send(content: frame, completion: .idempotent)
    }

    // MARK: - WebSocket Handshake Helpers

    private func extractWebSocketKey(from data: Data) -> String? {
        guard let text = String(bytes: data, encoding: .utf8) else { return nil }
        for line in text.components(separatedBy: "\r\n") {
            if line.lowercased().hasPrefix("sec-websocket-key:") {
                return line.dropFirst("sec-websocket-key:".count)
                    .trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    /// Computes the RFC 6455 §4.2.2 accept value: base64(SHA-1(key + GUID))
    private func webSocketAccept(for key: String) -> String? {
        let magic = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
        let combined = key + magic
        guard let data = combined.data(using: .utf8) else { return nil }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return Data(digest).base64EncodedString()
    }
}
