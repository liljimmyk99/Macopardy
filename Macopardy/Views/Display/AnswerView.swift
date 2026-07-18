//
//  AnswerView.swift
//  Macopardy
//

import SwiftUI

struct AnswerView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        if let question = gameState.currentQuestion {
            VStack(spacing: 48) {
                Spacer()

                Text(question.response)
                    .font(JeopardyTheme.answerFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(JeopardyTheme.clueBackground)
        }
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentQuestion = JeopardyBoard.sample.categories[0].questions[0]
    gameState.phase = .answer

    return AnswerView()
        .environment(gameState)
        .frame(width: 960, height: 540)
}
