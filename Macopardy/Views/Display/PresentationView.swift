//
//  PresentationView.swift
//  Macopardy
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

        case .finalJeopardy:
            FinalJeopardyView()
        }
    }
}

#Preview {
    PresentationView()
        .environment(GameState())
        .frame(width: 960, height: 540)
}
