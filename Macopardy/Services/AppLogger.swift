//
//  LoggingService.swift
//  Macopardy
//
//  Created by Jimmy Kane on 9/20/26.
//

import Foundation
import OSLog

public enum AppLogger {
    // Dynamically fetch your bundle ID to use as the subsystem
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.app.default"

    // Static immutable Logger instances are implicitly Sendable and thread-safe
    public static let control = Logger(subsystem: subsystem, category: "Control")
    public static let display = Logger(subsystem: subsystem, category: "Display")
    public static let database = Logger(subsystem: subsystem, category: "Storage")
}
