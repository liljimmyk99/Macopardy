import SwiftUI

extension TimerControlsView {
    /// Whole seconds left, rounded up so "1" shows until the timer hits zero.
    private var secondsLeft: Int {
        Int(gameState.timer.remainingTime.rounded(.up))
    }

    private var progress: Double {
        let total = max(gameState.timer.startingTime, gameState.timer.remainingTime)
        return total > 0 ? gameState.timer.remainingTime / total : 0
    }

    func timerDisplayRow() -> some View {
        ZStack {
            Circle()
                .stroke(MacpardyTheme.tileBlue, lineWidth: 12)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(MacpardyTheme.gold, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
            Text("\(secondsLeft)")
                .font(MacpardyTheme.controlTimerFont)
        }
        .frame(width: 150, height: 150)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("control.timer.seconds_left \(secondsLeft)"))
    }
}
