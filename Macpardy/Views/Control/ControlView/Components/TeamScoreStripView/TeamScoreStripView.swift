//
//  TeamScoreStripView.swift
//  Macpardy
//
//  Team scores along the bottom of the Control window, like the Display's scoreboard.
//

import SwiftUI

struct TeamScoreStripView: View {

    @Environment(GameState.self) var gameState

    let mode: TeamScoreStripMode

    var body: some View {
        HStack(spacing: 8) {
            ForEach(gameState.game.teams) { team in
                TeamScoreCard(team: team, mode: mode)
            }
        }
        .padding([.horizontal, .bottom], 8)
    }
}

#Preview {
    let gameState = GameState()
    gameState.game.teams = Team.sampleTeams

    return TeamScoreStripView(mode: .clue(amount: 400, dailyDoubleTeamID: nil))
        .environment(gameState)
        .environment(BuzzerState())
        .frame(width: 1100)
        .background(MacpardyTheme.boardBlue)
}
