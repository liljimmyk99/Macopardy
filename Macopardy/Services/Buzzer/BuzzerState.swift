//
//  BuzzerState.swift
//  Macopardy
//
//  @Observable bridge between the BuzzerServer actor and SwiftUI views.
//  Inject this into the environment via MacopardyApp.
//

import Foundation
import Network
import OSLog

@Observable
final class BuzzerState {

    // MARK: - Published Properties

    /// The 6-character code phones must enter to join.
    private(set) var joinCode: String = ""

    /// Full URL (including join code) that should be displayed / encoded as QR.
    private(set) var serverURL: URL?

    /// Number of phones that have authenticated with a valid join code.
    private(set) var connectedClientCount: Int = 0

    /// Whether the server is currently running.
    private(set) var isRunning: Bool = false

    /// Human-readable reason the server could not start (or stopped), if any.
    private(set) var startError: String?

    /// Teams that currently have a phone attached.
    private(set) var claimedTeamIDs: Set<UUID> = []

    /// Teams that had a phone at some point this session but have none now.
    /// Teams that never had a phone are not listed, so a game without buzzers
    /// shows no warnings.
    var disconnectedTeamIDs: Set<UUID> { everClaimedTeamIDs.subtracting(claimedTeamIDs) }

    /// The team that buzzed in first and is answering, if any.
    private(set) var firstBuzzTeamID: UUID?

    // MARK: - Private

    private var latestScores: [UUID: Int] = [:]
    private var latestMode: BuzzerMode = .disabled
    private var firstBuzzObserverTask: Task<Void, Never>?
    private var everClaimedTeamIDs: Set<UUID> = []
    private var latestTeams: [BuzzerTeam] = []
    private var server: BuzzerServer?
    private var countObserverTask: Task<Void, Never>?
    private var claimedObserverTask: Task<Void, Never>?
    private var failureObserverTask: Task<Void, Never>?

    // MARK: - Teams

    /// Pushes the app's current teams to the server (and remembers them for a
    /// server that has not started yet).
    func syncTeams(_ teams: [BuzzerTeam]) async {
        latestTeams = teams
        await server?.updateTeams(teams)
    }

    /// Pushes team scores to the server; they break ties between simultaneous buzzes.
    func syncScores(_ scores: [UUID: Int]) async {
        latestScores = scores
        await server?.updateScores(scores)
    }

    // MARK: - Buzzer control

    /// Sets up the buzzers for the screen being shown. Clears lockouts.
    func setMode(_ mode: BuzzerMode) async {
        latestMode = mode
        await server?.setBuzzerMode(mode)
    }

    /// Locks the team out for the question and re-arms the other teams.
    func teamAnsweredWrong(_ teamID: UUID) async {
        await server?.markWrong(teamID: teamID)
    }

    func teamAnsweredCorrect() async {
        await server?.markCorrect()
    }

    /// Frees a team's slot and disconnects its phone with "Removed by host".
    func removePhone(forTeam teamID: UUID) async {
        await server?.removePhone(forTeam: teamID)
    }

    // MARK: - Lifecycle

    /// Generates a new join code, resolves the local IP, and starts the server.
    /// Safe to call from a `Task { }` in a `.task` or `.onChange` modifier.
    func startServer() async {
        // Stop any existing server first.
        await stopServer()

        startError = nil

        // Resolve local IP before starting so the URL is ready immediately.
        guard let ip = localIPAddress() else {
            startError = "No local network address found. Connect to Wi-Fi or Ethernet."
            AppLogger.buzzer.error("Buzzer server not started — no local IPv4 address")
            return
        }

        let code = JoinCodeGenerator.generate()
        let newServer = BuzzerServer(joinCode: code)
        let urlString = "http://\(ip):\(BuzzerConstants.port)?code=\(code)"

        do {
            try await newServer.start()
            self.server = newServer
            self.joinCode = code
            self.serverURL = URL(string: urlString)
            self.isRunning = true
            AppLogger.buzzer.info("Buzzer server started at \(urlString)")

            await newServer.updateTeams(latestTeams)
            await newServer.updateScores(latestScores)
            await newServer.setBuzzerMode(latestMode)

            firstBuzzObserverTask = Task { [weak self, stream = newServer.firstBuzzStream] in
                for await teamID in stream {
                    guard let self else { return }
                    self.firstBuzzTeamID = teamID
                }
            }

            // Track which teams have a phone attached.
            claimedObserverTask = Task { [weak self, stream = newServer.claimedTeamsStream] in
                for await claimed in stream {
                    guard let self else { return }
                    self.claimedTeamIDs = claimed
                    self.everClaimedTeamIDs.formUnion(claimed)
                }
            }

            // Observe connected-client count changes from the server.
            countObserverTask = Task { [weak self, stream = newServer.connectedCountStream] in
                for await count in stream {
                    guard let self else { return }
                    self.connectedClientCount = count
                }
            }

            // Surface listener failures that happen after startup.
            failureObserverTask = Task { [weak self, stream = newServer.listenerFailureStream] in
                for await message in stream {
                    guard let self else { return }
                    self.startError = message
                    self.isRunning = false
                }
            }
        } catch {
            startError = error.localizedDescription
            AppLogger.buzzer.error("Failed to start buzzer server: \(error)")
        }
    }

    /// Stops the server and clears all state.
    func stopServer() async {
        countObserverTask?.cancel()
        countObserverTask = nil
        claimedObserverTask?.cancel()
        claimedObserverTask = nil
        failureObserverTask?.cancel()
        failureObserverTask = nil
        firstBuzzObserverTask?.cancel()
        firstBuzzObserverTask = nil
        firstBuzzTeamID = nil
        await server?.stop()
        server = nil
        isRunning = false
        connectedClientCount = 0
        claimedTeamIDs = []
        everClaimedTeamIDs = []
    }

    /// Broadcasts the current game phase to all connected phones.
    func broadcastPhase(_ phase: String) async {
        await server?.broadcast(.state(phase: phase))
    }

    // MARK: - Local IP Resolution

    /// Returns the IPv4 address phones on the local network can most likely reach.
    /// Prefers `en*` interfaces (Wi-Fi / Ethernet) and ignores VPN, bridge and
    /// AirDrop interfaces; falls back to any other non-loopback IPv4 address.
    private func localIPAddress() -> String? {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        defer { freeifaddrs(ifaddr) }

        var preferred: String?
        var fallback: String?
        let ignoredPrefixes = ["utun", "bridge", "awdl", "llw", "ap", "gif", "stf"]

        var ptr = ifaddr
        while let interface = ptr {
            defer { ptr = interface.pointee.ifa_next }

            guard let addr = interface.pointee.ifa_addr else { continue }
            let flags = Int32(interface.pointee.ifa_flags)
            guard (flags & IFF_UP) != 0, (flags & IFF_LOOPBACK) == 0,
                  addr.pointee.sa_family == UInt8(AF_INET) else { continue }

            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            guard getnameinfo(
                addr, socklen_t(addr.pointee.sa_len),
                &hostname, socklen_t(hostname.count),
                nil, 0, NI_NUMERICHOST
            ) == 0 else { continue }

            let name = String(cString: interface.pointee.ifa_name)
            let ip = String(cString: hostname)

            if name.hasPrefix("en") {
                preferred = preferred ?? ip
            } else if !ignoredPrefixes.contains(where: { name.hasPrefix($0) }) {
                fallback = fallback ?? ip
            }
        }
        return preferred ?? fallback
    }
}

extension BuzzerTeam {
    /// The phone-facing view of a game team. `claimed` is filled in by the server.
    init(team: Team) {
        self.init(id: team.id, name: team.name, color: team.color, claimed: false)
    }
}

// For getifaddrs / getnameinfo
import Darwin
