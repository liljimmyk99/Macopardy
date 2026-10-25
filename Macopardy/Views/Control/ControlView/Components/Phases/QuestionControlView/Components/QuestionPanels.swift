import SwiftUI

extension QuestionControlView {
    func clueCard(_ question: Question) -> some View {
        Text(question.clue.uppercased())
            .font(MacpardyTheme.controlClueFont)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.4)
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(MacpardyTheme.tileBlue)
            .overlay(alignment: .bottomTrailing) {
                if question.image != nil {
                    Label("control.question.has_picture", systemImage: "photo")
                        .font(.caption)
                        .foregroundStyle(MacpardyTheme.mutedText)
                        .padding(12)
                }
            }
    }

    func responseBar(_ question: Question) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "eye")
                .font(.title3)
                .foregroundStyle(MacpardyTheme.gold)

            VStack(alignment: .leading, spacing: 2) {
                Text("control.question.response_host_only")
                    .font(.caption.bold())
                    .foregroundStyle(MacpardyTheme.mutedText)
                Text(question.response)
                    .font(MacpardyTheme.controlResponseFont)
                    .foregroundStyle(MacpardyTheme.gold)
            }

            Spacer()

            Button {
                gameState.revealAnswer()
            } label: {
                Text(gameState.phase == .answer ? "control.question.button.answer_revealed" : "control.question.button.reveal_answer")
                    .font(.headline)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(MacpardyTheme.gold)
            .foregroundStyle(MacpardyTheme.boardBlue)
            .controlSize(.extraLarge)
            .disabled(gameState.phase == .answer)
        }
        .padding(16)
        .background(MacpardyTheme.panelBlue)
        .overlay(
            Rectangle()
                .strokeBorder(MacpardyTheme.gold.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
        )
    }

    /// The Daily Double team and wager, or who buzzed first. Hidden on a normal
    /// clue when no phone has joined.
    @ViewBuilder
    func buzzStatusCard() -> some View {
        if let teamID = gameState.dailyDoubleTeamID,
           let team = gameState.game.teams.first(where: { $0.id == teamID }) {
            statusCard(
                caption: "control.question.daily_double_caption",
                title: team.name,
                detail: Text("control.question.daily_double_wager \(gameState.dailyDoubleWager)"),
                accent: MacpardyTheme.gold
            )
        } else if buzzerState.connectedClientCount > 0 {
            if let teamID = buzzerState.firstBuzzTeamID,
               let team = gameState.game.teams.first(where: { $0.id == teamID }) {
                statusCard(
                    caption: "control.question.buzzed_first_caption",
                    title: team.name,
                    detail: nil,
                    accent: team.displayColor
                )
            } else {
                Label("control.question.waiting_for_buzz", systemImage: "bolt.slash")
                    .font(.callout)
                    .foregroundStyle(MacpardyTheme.mutedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(MacpardyTheme.panelBlue)
            }
        }
    }

    private func statusCard(caption: LocalizedStringKey, title: String, detail: Text?, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(caption)
                .font(.caption.bold())
                .foregroundStyle(MacpardyTheme.mutedText)
            Text(title)
                .font(.title.bold())
            if let detail {
                detail
                    .font(.subheadline)
                    .foregroundStyle(MacpardyTheme.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(accent.opacity(0.18))
        .background(MacpardyTheme.panelBlue)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(accent)
                .frame(width: 6)
        }
    }
}
