//
//  LoggingService.swift
//  Macpardy
//
//  Created by Jimmy Kane on 9/20/26.
//

import Foundation
import OSLog

public enum AppLogger {
    // Dynamically fetch your bundle ID to use as the subsystem
    private nonisolated static let subsystem = Bundle.main.bundleIdentifier ?? "com.app.default"

    // Static immutable Logger instances are implicitly Sendable and thread-safe.
    // Marked nonisolated so they can be accessed from any actor context.
    public nonisolated static let control = Logger(subsystem: subsystem, category: "Control")
    public nonisolated static let display = Logger(subsystem: subsystem, category: "Display")
    public nonisolated static let database = Logger(subsystem: subsystem, category: "Storage")
    public nonisolated static let buzzer = Logger(subsystem: subsystem, category: "Buzzer")
}
