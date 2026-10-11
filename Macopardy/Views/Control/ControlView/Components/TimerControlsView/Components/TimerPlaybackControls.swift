import SwiftUI

extension TimerControlsView {
    func timerPlaybackControls() -> some View {
        HStack(spacing: 8) {
            controlButton("Start", systemImage: "play.fill") {
                gameState.timer.start()
            }

            controlButton("Pause", systemImage: "pause.fill") {
                gameState.timer.stop()
            }

            controlButton("Reset", systemImage: "arrow.counterclockwise") {
                gameState.timer.reset()
            }
        }
    }

    func controlButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}
