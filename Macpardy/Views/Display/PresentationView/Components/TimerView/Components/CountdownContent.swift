import SwiftUI

extension TimerView {
    func countdownContent() -> some View {
        CountdownView(seconds: Int(gameState.timer.remainingTime))
    }
}
