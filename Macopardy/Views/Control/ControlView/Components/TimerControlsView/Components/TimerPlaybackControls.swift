import SwiftUI

extension TimerControlsView {
    func timerPlaybackControls() -> some View {
        HStack(spacing: 8) {
            controlButton("control.timer.start", systemImage: "play.fill") {
                gameState.timer.start()
            }

            controlButton("control.timer.pause", systemImage: "pause.fill") {
                gameState.timer.stop()
            }

            controlButton("control.timer.reset", systemImage: "arrow.counterclockwise") {
                gameState.timer.reset()
            }
        }
    }

    func controlButton(
        _ title: LocalizedStringKey,
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
