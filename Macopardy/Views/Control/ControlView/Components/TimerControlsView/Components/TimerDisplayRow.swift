import SwiftUI

extension TimerControlsView {
    func timerDisplayRow() -> some View {
        HStack {
            Text("Remaining")
            Spacer()
            Text("\(gameState.timer.remainingTime)s")
                .font(.title2.monospacedDigit())
                .fontWeight(.semibold)
        }
    }
}
