//
//  ClientSession.swift
//  Macopardy
//
//  Represents a single connected WebSocket client (one phone browser tab).
//

import Foundation
import Network
import OSLog

/// Tracks the state of a single WebSocket client connection.
///
/// Marked `@unchecked Sendable` because its mutable state (`lastPong`,
/// `isAuthenticated`) is always mutated from within the `BuzzerServer` actor.
nonisolated final class ClientSession: Identifiable, @unchecked Sendable {

    nonisolated let id = UUID()

    /// The underlying Network.framework connection for this client.
    nonisolated let connection: NWConnection

    /// Timestamp of the last pong received from this client.
    /// Always mutated from within the BuzzerServer actor.
    var lastPong: Date = Date()

    /// Whether this client has successfully sent a valid join code.
    /// Always mutated from within the BuzzerServer actor.
    var isAuthenticated: Bool = false

    /// When the WebSocket handshake completed; used to evict clients that never join.
    let connectedAt = Date()

    /// Bytes received but not yet parsed into complete WebSocket frames.
    /// Always mutated from within the BuzzerServer actor.
    var receiveBuffer = Data()

    /// Payload of an in-progress fragmented text message (opcode 0x1 without FIN).
    var fragmentBuffer: Data?

    nonisolated init(connection: NWConnection) {
        self.connection = connection
    }

    // MARK: - Sending

    /// Encodes `message` as JSON and sends it as a WebSocket text frame.
    nonisolated func send(_ message: ServerMessage, closeAfterSending: Bool = false) {
        guard let data = try? message.jsonData() else {
            AppLogger.buzzer.error("[\(self.id)] Failed to encode message for sending")
            return
        }
        var frame = Data()
        let len = data.count
        frame.append(0x81)   // FIN + opcode text (0x1)
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
        frame.append(contentsOf: data)
        connection.send(content: frame, completion: .contentProcessed { [connection] error in
            if let error {
                AppLogger.buzzer.error("[\(self.id)] Failed to send message: \(error)")
            }
            if closeAfterSending {
                connection.cancel()
            }
        })
    }

    /// Closes the WebSocket connection cleanly.
    nonisolated func close() {
        connection.cancel()
    }
}
