import SwiftUI

extension TimerControlsView {
    func timerPlaybackControls() -> some View {
        HStack(spacing: 6) {
            Button("control.timer.adjustment.minus_5") {
                gameState.timer.addSeconds(-5)
            }

            if gameState.timer.isRunning {
                iconButton("pause.fill", label: "control.timer.pause") {
                    gameState.timer.stop()
                }
            } else {
                iconButton("play.fill", label: "control.timer.start") {
                    gameState.timer.start()
                }
            }

            iconButton("arrow.counterclockwise", label: "control.timer.reset") {
                gameState.timer.reset()
            }

            Button("control.timer.adjustment.plus_5") {
                gameState.timer.addSeconds(5)
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }

    private func iconButton(_ systemImage: String, label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: 28)
        }
        .accessibilityLabel(Text(label))
        .help(Text(label))
    }
}
