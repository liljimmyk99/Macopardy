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
                .foregroundStyle(pulseColor ?? .white)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(team.score)))
                .scaleEffect(pulseColor == nil ? 1 : 1.2)
                .animation(animationsEnabled ? MacpardyMotion.scorePulse : nil, value: team.score)
                .onChange(of: team.score) { old, new in
                    pulseScore(from: old, to: new)
                }

            if isDisconnected {
                Label("display.team.disconnected", systemImage: "iphone.slash")
                    .font(compact ? .caption2 : .caption)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// Flashes the score gold when it goes up and red when it goes down.
    private func pulseScore(from old: Int, to new: Int) {
        guard animationsEnabled, old != new else { return }
        withAnimation(MacpardyMotion.scorePulse) {
            pulseColor = new > old ? MacpardyTheme.gold : MacpardyTheme.warning
        }
        Task {
            try? await Task.sleep(for: .milliseconds(700))
            withAnimation(MacpardyMotion.quick) { pulseColor = nil }
        }
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
            ResponseTimerDots(lit: 0, total: AppSettings.responseSeconds(), dotSize: 14)
                .hidden()
                .accessibilityHidden(true)
        }
    }
}
