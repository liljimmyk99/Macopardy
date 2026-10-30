import SwiftUI

extension DailyDoubleControlView {
    var defaultWagerValue: Int {
        gameState.currentQuestion?.value ?? 1000
    }

    var selectedTeamBinding: Binding<UUID> {
        Binding(
            get: { selectedTeamID ?? gameState.game.teams.first?.id ?? UUID() },
            set: { selectedTeamID = $0 }
        )
    }

    var parsedWagerValue: Int {
        Int(wagerText) ?? defaultWagerValue
    }
}
