//
//  SetupControlView.swift
//  Macpardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

/// Team cards on the left, phone buzzer join info and Start Game on the right.
struct SetupControlView: View {

    @Environment(GameState.self) var gameState
    @Environment(BuzzerState.self) var buzzerState

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(spacing: 4) {
                sectionHeader("control.setup.teams_header \(gameState.game.teams.count) \(Team.maxCount)")
                teamGrid()
            }

            VStack(spacing: 4) {
                sectionHeader("control.setup.buzzer.title")
                VStack(spacing: 18) {
                    BuzzerJoinInfoView()
                    Spacer(minLength: 0)
                    startGameButton()
                }
                .padding(24)
                .frame(maxHeight: .infinity)
                .background(MacpardyTheme.panelBlue)
            }
            .frame(width: 380)
        }
        .padding(8)
    }
}

#Preview {
    let gameState = GameState()
    gameState.game.teams = Team.defaultNewTeams

    return SetupControlView()
        .environment(gameState)
        .environment(BuzzerState())
        .frame(width: 1200, height: 720)
        .background(MacpardyTheme.boardBlue)
}
