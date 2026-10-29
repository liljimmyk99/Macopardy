//
//  PresentationView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct PresentationView: View {

    @Environment(GameState.self) var gameState
    @Environment(BuzzerState.self) var buzzerState

    var body: some View {
        VStack(spacing: 0) {
            phaseContent

            ScoreboardView(
                teams: gameState.game.teams,
                disconnectedTeamIDs: buzzerState.disconnectedTeamIDs,
                responseCountdown: gameState.responseCountdown
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MacpardyTheme.boardBlue)
    }
}

#Preview {
    PresentationView()
        .environment(GameState())
        .environment(BuzzerState())
        .frame(width: 960, height: 540)
}
