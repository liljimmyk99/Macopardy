//
//  FinalJeopardyView.swift
//  Macopardy
//

import SwiftUI

struct FinalJeopardyView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        VStack(spacing: 48) {
            Spacer()

            Text("FINAL JEOPARDY")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(JeopardyTheme.gold)

            if let categoryTitle = gameState.currentCategoryTitle {
                VStack(spacing: 12) {
                    Text("Category")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))

                    Text(categoryTitle.uppercased())
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }

            TimerView()

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(JeopardyTheme.clueBackground)
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentCategoryTitle = "Think Music"
    gameState.phase = .finalJeopardy

    return FinalJeopardyView()
        .environment(gameState)
        .frame(width: 960, height: 540)
}
