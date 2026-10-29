//
//  ResponseCountdown.swift
//  Macopardy
//
//  The answering team's response time as the Control window, the Display and
//  the phones show it (issue #59).
//

import Foundation

nonisolated struct ResponseCountdown: Equatable {
    /// The team that buzzed in and is answering.
    let teamID: UUID
    /// Whole seconds left, rounded up so the last second shows until zero. 0 once time is up.
    let secondsLeft: Int
    /// The full response time, in seconds.
    let totalSeconds: Int

    var isExpired: Bool { secondsLeft <= 0 }

    init(teamID: UUID, remainingTime: TimeInterval, totalTime: TimeInterval) {
        self.teamID = teamID
        // GameTimer counts down in 0.1 s steps, so snap to tenths first: otherwise
        // float drift (4.0000001) would round up and hold a second too long.
        let tenths = (remainingTime * 10).rounded() / 10
        self.secondsLeft = max(0, Int(tenths.rounded(.up)))
        self.totalSeconds = max(0, Int(totalTime.rounded(.up)))
    }
}
