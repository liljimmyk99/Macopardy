import SwiftUI

extension TimerControlsView {
    func timerPlaybackControls() -> some View {
        HStack(spacing: 6) {
            Button("control.timer.adjustment.minus_5") {
                gameState.timer.addSeconds(-5)
            }
            .keyboardShortcut("-", modifiers: .command)

            if gameState.timer.isRunning {
                iconButton(
                    "pause.fill",
                    label: "control.timer.pause",
                    keyboardShortCut: .init("s", modifiers: .command)
                ) {
                    gameState.timer.stop()
                }
            } else {
                iconButton(
                    "play.fill",
                    label: "control.timer.start",
                    keyboardShortCut: .init("s", modifiers: .command)
                ) {
                    gameState.timer.start()
                }
            }

            iconButton(
                "arrow.counterclockwise",
                label: "control.timer.reset",
                keyboardShortCut: .init(.leftArrow, modifiers: .command)
            ) {
                gameState.timer.reset()
            }

            Button("control.timer.adjustment.plus_5") {
                gameState.timer.addSeconds(5)
            }
            .keyboardShortcut("+", modifiers: .command)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }

    private func iconButton(
        _ systemImage: String,
        label: LocalizedStringKey,
        keyboardShortCut: KeyboardShortcut,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: 28)
        }
        .accessibilityLabel(Text(label))
        .keyboardShortcut(keyboardShortCut)
        .help(Text(label))
    }
}
