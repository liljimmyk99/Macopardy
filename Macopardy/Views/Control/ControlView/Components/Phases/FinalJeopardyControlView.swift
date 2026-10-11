//
//  Phase6FinalJeopardyControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct FinalJeopardyControlView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        VStack(spacing: 20) {
            // Header Info & Navigation
            HStack {
                Text("FINAL JEOPARDY")
                    .font(.headline)
                    .foregroundStyle(JeopardyTheme.gold)

                if let categoryTitle = gameState.currentCategoryTitle {
                    Text("• \(categoryTitle.uppercased())")
                        .font(.headline)
                        .foregroundStyle(.secondary)
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
                GroupBox("Final Jeopardy Clue & Answer") {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("FINAL JEOPARDY CLUE")
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
                    title: gameState.phase == .finalJeopardyAnswer ? "Answer Revealed" : "Reveal Answer",
                    systemImage: "eye.fill",
                    tint: gameState.phase == .finalJeopardyAnswer ? .secondary : .accentColor
                ) {
                    gameState.revealAnswer()
                }
                .disabled(gameState.phase == .finalJeopardyAnswer)

                Spacer()
            }

            // 30s Timer Controls
            TimerControlsView()

            // Final Jeopardy Score Controls (applies each team's wager)
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
