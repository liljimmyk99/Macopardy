import SwiftUI

extension FinalJeopardyControlView {
    func finalJeopardyHeader() -> some View {
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
    }

    func finalJeopardyQuestionDetails() -> some View {
        Group {
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
        }
    }

    func revealAnswerButton() -> some View {
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
    }
}
