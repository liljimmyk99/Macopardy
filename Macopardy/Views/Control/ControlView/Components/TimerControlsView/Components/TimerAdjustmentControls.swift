import SwiftUI

extension TimerControlsView {
    func timerAdjustmentControls() -> some View {
        HStack(spacing: 8) {
            controlButton("+5", systemImage: "plus") {
                gameState.timer.addSeconds(5)
            }

            controlButton("-5", systemImage: "minus") {
                gameState.timer.addSeconds(-5)
            }
        }
    }
}
