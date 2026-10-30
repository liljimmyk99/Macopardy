//
//  BuzzerStatusButton+Extension.swift
//  Macpardy
//

import SwiftUI

extension BuzzerStatusButton {
    /// Teams in this game whose phone is currently joined.
    var connectedTeamCount: Int {
        gameState.game.teams.filter { buzzerState.claimedTeamIDs.contains($0.id) }.count
    }

    var title: LocalizedStringKey {
        guard buzzerState.isRunning else { return "control.toolbar.buzzers.off" }
        return "control.toolbar.buzzers \(buzzerState.joinCode) \(connectedTeamCount) \(gameState.game.teams.count)"
    }

    /// Orange when a phone dropped, green when any are joined, red if the server failed.
    var statusColor: Color {
        if buzzerState.startError != nil { return .red }
        if !buzzerState.disconnectedTeamIDs.isEmpty { return .orange }
        if connectedTeamCount > 0 { return .green }
        return .secondary
    }
}
