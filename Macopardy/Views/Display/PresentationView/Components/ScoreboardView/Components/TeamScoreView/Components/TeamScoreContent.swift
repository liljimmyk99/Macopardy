import SwiftUI

extension TeamScoreView {
    func teamScoreContent() -> some View {
        VStack(spacing: compact ? 4 : 8) {
            Text(team.name)
                .font(compact ? .headline : .title2)
                .fontWeight(.semibold)
                .foregroundStyle(team.displayColor)

            responseDots

            Text("\(team.score)")
                .font(compact ? MacpardyTheme.scoreFont : .system(size: 40, weight: .bold))
                .foregroundStyle(.white)
                .monospacedDigit()

            if isDisconnected {
                Label("display.team.disconnected", systemImage: "iphone.slash")
                    .font(compact ? .caption2 : .caption)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// The answering team's response time above its total. The full-size
    /// scoreboard keeps the row's space for every team so it doesn't jump
    /// when a team buzzes in.
    @ViewBuilder
    private var responseDots: some View {
        if let responseCountdown {
            ResponseTimerDots(
                lit: responseCountdown.secondsLeft,
                total: responseCountdown.totalSeconds,
                dotSize: compact ? 8 : 14
            )
        } else if !compact {
            ResponseTimerDots(lit: 0, total: Int(GameState.responseSeconds), dotSize: 14)
                .hidden()
                .accessibilityHidden(true)
        }
    }
}
