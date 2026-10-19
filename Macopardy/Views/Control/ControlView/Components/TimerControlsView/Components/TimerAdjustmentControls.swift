import SwiftUI

extension TimerControlsView {
    func timerAdjustmentControls() -> some View {
        HStack(spacing: 8) {
            controlButton("control.timer.adjustment.plus_5", systemImage: "plus") {
                gameState.timer.addSeconds(5)
            }

            controlButton("control.timer.adjustment.minus_5", systemImage: "minus") {
                gameState.timer.addSeconds(-5)
            }
        }
    }
}
