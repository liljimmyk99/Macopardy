//
//  BuzzerMessage.swift
//  Macopardy
//
//  Versioned JSON message protocol for the buzzer WebSocket connection.
//  All messages use a top-level `type` string field plus an optional `payload`.
//
//  Server → Phone: ServerMessage
//  Phone → Server: ClientMessage
//

import Foundation

// MARK: - Server → Phone

/// Messages sent by the server to a connected phone client.
nonisolated enum ServerMessage {
    /// Sent after a valid join code is received. Carries team names so the
    /// phone can render a team-picker in a future sub-issue.
    case joinAccepted(teamNames: [String])

    /// Sent when the join code is wrong. The phone should display an error
    /// and not attempt to reconnect with the same code.
    case joinRejected(reason: String)

    /// Heartbeat request. The phone must respond with a `pong` client message
    /// within `BuzzerConstants.heartbeatTTL` seconds or be disconnected.
    case ping

    /// Broadcast when the game phase changes so the phone can update its UI.
    case state(phase: String)
}

extension ServerMessage: Encodable {
    private enum CodingKeys: String, CodingKey {
        case type, payload
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .joinAccepted(let teamNames):
            try container.encode("joinAccepted", forKey: .type)
            var payload = container.nestedContainer(keyedBy: PayloadKeys.self, forKey: .payload)
            try payload.encode(teamNames, forKey: .teams)
            try payload.encode(BuzzerConstants.protocolVersion, forKey: .version)

        case .joinRejected(let reason):
            try container.encode("joinRejected", forKey: .type)
            var payload = container.nestedContainer(keyedBy: PayloadKeys.self, forKey: .payload)
            try payload.encode(reason, forKey: .reason)

        case .ping:
            try container.encode("ping", forKey: .type)

        case .state(let phase):
            try container.encode("state", forKey: .type)
            var payload = container.nestedContainer(keyedBy: PayloadKeys.self, forKey: .payload)
            try payload.encode(phase, forKey: .phase)
        }
    }

    private enum PayloadKeys: String, CodingKey {
        case teams, version, reason, phase
    }
}

// MARK: - Phone → Server

/// Messages sent by a phone client to the server.
nonisolated enum ClientMessage {
    /// First message a phone sends after the WebSocket connection opens.
    /// `version` must match `BuzzerConstants.protocolVersion`.
    case join(code: String, version: Int)

    /// Response to a `ping`. Resets the client's heartbeat TTL.
    case pong
}

extension ClientMessage: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type, code, version
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type_ = try container.decode(String.self, forKey: .type)
        switch type_ {
        case "join":
            let code = try container.decode(String.self, forKey: .code)
            let version = try container.decode(Int.self, forKey: .version)
            self = .join(code: code, version: version)
        case "pong":
            self = .pong
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown client message type: \(type_)"
            )
        }
    }
}

// MARK: - Helpers

extension ServerMessage {
    /// Encodes the message to a UTF-8 JSON `Data` blob ready for transmission.
    nonisolated func jsonData() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
