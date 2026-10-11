import SwiftUI

extension QuestionControlView {
    func questionHeader() -> some View {
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
    }

    func questionDetails() -> some View {
        Group {
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
        }
    }

    func revealAnswerButton() -> some View {
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
    }
}
