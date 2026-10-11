//
//  FinalJeopardyControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct FinalJeopardyControlView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        VStack(spacing: 20) {
            finalJeopardyHeader()
            finalJeopardyQuestionDetails()
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
    gameState.showFinalJeopardy(categoryTitle: "Science")
    gameState.revealFinalJeopardyQuestion()

    return FinalJeopardyControlView()
        .environment(gameState)
}
