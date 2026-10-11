//
//  PresentationView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct PresentationView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        VStack(spacing: 0) {
            phaseContent

            ScoreboardView(teams: gameState.game.teams)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(JeopardyTheme.boardBlue)
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch gameState.phase {
        case .setup:
            VStack(spacing: 20) {
                Spacer()
                GameTitleView(title: "Jeopardy!")
                Text("Waiting to start game...")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(JeopardyTheme.boardBlue)

        case .board:
            if let board = gameState.game.currentBoard {
                BoardView(board: board)
            }

        case .question:
            QuestionView()

        case .answer:
            AnswerView()

        case .dailyDouble:
            DailyDoubleView()

        case .finalJeopardyCategory, .finalJeopardyQuestion, .finalJeopardyAnswer:
            FinalJeopardyView()
        }
    }
}

#Preview {
    PresentationView()
        .environment(GameState())
        .frame(width: 960, height: 540)
}
