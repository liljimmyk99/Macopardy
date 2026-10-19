//
//  Phase3QuestionControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct QuestionControlView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        VStack(spacing: 20) {
            questionHeader()
            questionDetails()
            revealAnswerButton()
            TimerControlsView()
            ScoreControlsView()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentQuestion = MacpardyBoard.sample.categories[0].questions[0]
    gameState.currentCategoryTitle = "Science"
    gameState.phase = .question

    return QuestionControlView()
        .environment(gameState)
}
