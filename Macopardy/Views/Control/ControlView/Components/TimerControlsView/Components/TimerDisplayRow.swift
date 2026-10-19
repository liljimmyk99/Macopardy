import SwiftUI

extension TimerControlsView {
    func timerDisplayRow() -> some View {
        HStack {
            Text("control.timer.remaining")
            Spacer()
            Text("control.timer.seconds_format \(gameState.timer.remainingTime)")
                .font(.title2.monospacedDigit())
                .fontWeight(.semibold)
        }
    }
}
