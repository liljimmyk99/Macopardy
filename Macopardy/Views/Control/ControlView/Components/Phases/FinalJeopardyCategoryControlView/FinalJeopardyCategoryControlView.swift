//
//  FinalJeopardyCategoryControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct FinalJeopardyCategoryControlView: View {

    @Environment(GameState.self) var gameState
    @State var wagers: [UUID: String] = [:]

    var body: some View {
        VStack(spacing: 24) {
            finalJeopardyHeader()
            teamWagerGroup()
            revealQuestionButton()
            Spacer()
        }
        .padding()
        .onAppear {
            syncWagersFromGameState()
        }
    }
}

#Preview {
    let gameState = GameState()
    gameState.showFinalJeopardy(categoryTitle: "Think Music")

    return FinalJeopardyCategoryControlView()
        .environment(gameState)
}
