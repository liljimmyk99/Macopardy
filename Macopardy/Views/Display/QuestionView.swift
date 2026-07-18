//
//  QuestionView.swift
//  Macopardy
//

import SwiftUI

struct QuestionView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        if let question = gameState.currentQuestion {
            VStack(spacing: 40) {
                Spacer()

                if let categoryTitle = gameState.currentCategoryTitle {
                    Text(categoryTitle.uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(JeopardyTheme.gold)
                }

                QuestionValueView(value: question.value, font: .system(size: 48, weight: .bold))

                Text(question.clue)
                    .font(JeopardyTheme.clueFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)

                TimerView()

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(JeopardyTheme.clueBackground)
            .onAppear {
                
            }
        }
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentQuestion = JeopardyBoard.sample.categories[0].questions[0]
    gameState.currentCategoryTitle = "Science"
    gameState.phase = .question

    return QuestionView()
        .environment(gameState)
        .frame(width: 960, height: 540)
}
