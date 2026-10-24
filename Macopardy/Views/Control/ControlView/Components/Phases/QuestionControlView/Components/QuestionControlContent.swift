import SwiftUI

extension QuestionControlView {
    func questionHeader() -> some View {
        HStack {
            if let categoryTitle = gameState.currentCategoryTitle {
                Text(categoryTitle.uppercased())
                    .font(.headline)
                    .foregroundStyle(MacpardyTheme.gold)
            }

            if let question = gameState.currentQuestion {
                if gameState.dailyDoubleTeamID != nil {
                    Text("control.question.daily_double_header \(gameState.dailyDoubleWager)")
                        .font(.headline)
                        .foregroundStyle(MacpardyTheme.gold)
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
                Label("control.question.button.return_to_board", systemImage: "arrowshape.turn.up.backward.fill")
            }
            .buttonStyle(.bordered)
        }
    }

    /// Names the team that buzzed in first. Hidden when no phone has joined and
    /// during Daily Doubles, where buzzers are off.
    @ViewBuilder
    func buzzedFirstBanner() -> some View {
        if buzzerState.connectedClientCount > 0, gameState.dailyDoubleTeamID == nil {
            if let teamID = buzzerState.firstBuzzTeamID,
               let team = gameState.game.teams.first(where: { $0.id == teamID }) {
                HStack(spacing: 10) {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(MacpardyTheme.gold)
                    Circle()
                        .fill(team.displayColor)
                        .frame(width: 14, height: 14)
                    Text("control.question.buzzed_first \(team.name)")
                        .font(.title3.bold())
                    Spacer()
                }
                .padding(12)
                .background(MacpardyTheme.gold.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Label("control.question.waiting_for_buzz", systemImage: "bolt.slash")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    func questionDetails() -> some View {
        Group {
            if let question = gameState.currentQuestion {
                GroupBox("control.question.clue_and_answer_group") {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("control.question.clue_header")
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
                                .foregroundStyle(MacpardyTheme.gold)
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
                title: gameState.phase == .answer ? "control.question.button.answer_revealed" : "control.question.button.reveal_answer",
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
