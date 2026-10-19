import SwiftUI

extension FinalJeopardyControlView {
    func finalJeopardyHeader() -> some View {
        HStack {
            Text("display.final_jeopardy.header")
                .font(.headline)
                .foregroundStyle(JeopardyTheme.gold)

            if let categoryTitle = gameState.currentCategoryTitle {
                Text("• \(categoryTitle.uppercased())")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if gameState.phase == .finalJeopardyAnswer {
                Button(role: .destructive) {
                    Task {
                        await GameSaveStore.shared.clear()
                    }
                    gameState.phase = .setup
                } label: {
                    Label("control.final_jeopardy.button.complete_game", systemImage: "flag.checkered.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }

            Button {
                gameState.showBoard()
            } label: {
                Label("control.question.button.return_to_board", systemImage: "arrowshape.turn.up.backward.fill")
            }
            .buttonStyle(.bordered)
        }
    }

    func finalJeopardyQuestionDetails() -> some View {
        Group {
            if let question = gameState.currentQuestion {
                GroupBox("control.final_jeopardy.clue_and_answer_group") {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("control.final_jeopardy.clue_header")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Text(question.clue)
                                .font(.title3)
                                .fontWeight(.medium)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("control.question.correct_response_header")
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
                title: gameState.phase == .finalJeopardyAnswer ? "control.question.button.answer_revealed" : "control.question.button.reveal_answer",
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
