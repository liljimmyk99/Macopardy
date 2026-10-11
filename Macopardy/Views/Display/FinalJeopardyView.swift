//
//  FinalJeopardyView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct FinalJeopardyView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        VStack(spacing: 36) {
            Spacer()

            Text("FINAL JEOPARDY")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(JeopardyTheme.gold)

            if let categoryTitle = gameState.currentCategoryTitle {
                VStack(spacing: 8) {
                    Text("CATEGORY")
                        .font(.headline)
                        .foregroundStyle(JeopardyTheme.gold.opacity(0.8))

                    Text(categoryTitle.uppercased())
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }

            switch gameState.phase {
            case .finalJeopardyCategory:
                EmptyView()

            case .finalJeopardyQuestion:
                if let question = gameState.currentQuestion {
                    Text(question.clue)
                        .font(JeopardyTheme.clueFont)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                }
                TimerView()
                    .onAppear {
                        gameState.timer.start()
                    }

            case .finalJeopardyAnswer:
                if let question = gameState.currentQuestion {
                    Text(question.response)
                        .font(JeopardyTheme.answerFont)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                }

            default:
                EmptyView()
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(JeopardyTheme.clueBackground)
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentCategoryTitle = "Think Music"
    gameState.phase = .finalJeopardyCategory

    return FinalJeopardyView()
        .environment(gameState)
        .frame(width: 960, height: 540)
}
