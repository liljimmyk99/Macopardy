//
//  PresentationView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct PresentationView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        VStack(spacing: 0) {
            phaseContent

            ScoreboardView(teams: gameState.game.teams)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MacpardyTheme.boardBlue)
    }
}

#Preview {
    PresentationView()
        .environment(GameState())
        .frame(width: 960, height: 540)
}
