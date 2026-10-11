//
//  Phase3QuestionControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct QuestionControlView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        VStack(spacing: 20) {
            // Header Info & Navigation
            HStack {
                if let categoryTitle = gameState.currentCategoryTitle {
                    Text(categoryTitle.uppercased())
                        .font(.headline)
                        .foregroundStyle(JeopardyTheme.gold)
                }

                if let question = gameState.currentQuestion {
                    if gameState.dailyDoubleTeamID != nil {
                        Text("• Daily Double ($\(gameState.dailyDoubleWager))")
                            .font(.headline)
                            .foregroundStyle(JeopardyTheme.gold)
                    } else {
                        Text("• $\(question.value)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button {
                    gameState.showBoard()
                } label: {
                    Label("Return to Board", systemImage: "arrowshape.turn.up.backward.fill")
                }
                .buttonStyle(.bordered)
            }

            // Question and Answer displayed for Host
            if let question = gameState.currentQuestion {
                GroupBox("Clue & Answer") {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CLUE")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Text(question.clue)
                                .font(.title3)
                                .fontWeight(.medium)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("CORRECT RESPONSE")
                                .font(.caption.bold())
                                .foregroundStyle(JeopardyTheme.gold)
                            Text(question.response)
                                .font(.title3.bold())
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                }
            }

            // Action: Reveal Answer Button
            HStack {
                LargeButton(
                    title: gameState.phase == .answer ? "Answer Revealed" : "Reveal Answer",
                    systemImage: "eye.fill",
                    tint: gameState.phase == .answer ? .secondary : .accentColor
                ) {
                    gameState.revealAnswer()
                }
                .disabled(gameState.phase == .answer)

                Spacer()
            }

            // Timer Controls
            TimerControlsView()

            // Score Controls (Right/Wrong)
            ScoreControlsView()

            Spacer()
        }
        .padding()
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentQuestion = JeopardyBoard.sample.categories[0].questions[0]
    gameState.currentCategoryTitle = "Science"
    gameState.phase = .question

    return QuestionControlView()
        .environment(gameState)
}
