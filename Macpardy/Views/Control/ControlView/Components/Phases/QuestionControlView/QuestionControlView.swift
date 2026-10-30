//
//  QuestionControlView.swift
//  Macpardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

/// The clue as a big tile with the correct response (host only) under it,
/// and who buzzed plus the timer beside it. Scoring is in the team strip below.
struct QuestionControlView: View {

    @Environment(GameState.self) var gameState
    @Environment(BuzzerState.self) var buzzerState

    var body: some View {
        if let question = gameState.currentQuestion {
            HStack(spacing: 8) {
                VStack(spacing: 8) {
                    clueCard(question)
                    responseBar(question)
                }

                VStack(spacing: 8) {
                    buzzStatusCard()
                    TimerControlsView()
                        .frame(maxHeight: .infinity)
                }
                .frame(width: 320)
            }
            .padding(8)
        }
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentQuestion = MacpardyBoard.sample.categories[0].questions[0]
    gameState.currentCategoryTitle = "Science"
    gameState.phase = .question

    return QuestionControlView()
        .environment(gameState)
        .environment(BuzzerState())
        .frame(width: 1100, height: 560)
        .background(MacpardyTheme.boardBlue)
}
