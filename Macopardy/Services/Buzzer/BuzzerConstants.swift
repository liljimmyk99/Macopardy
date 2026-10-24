//
//  BuzzerConstants.swift
//  Macopardy
//
//  Central configuration for the embedded buzzer server.
//

import Foundation

nonisolated enum BuzzerConstants {
    /// TCP port the buzzer server listens on.
    static let port: UInt16 = 8472

    /// Seconds a client can go without sending a pong before being disconnected.
    static let heartbeatTTL: TimeInterval = 5.0

    /// How often the server sends a ping to each connected client.
    static let pingInterval: TimeInterval = 2.0

    /// Current wire-protocol version sent in joinAccepted messages.
    static let protocolVersion = 1
}
