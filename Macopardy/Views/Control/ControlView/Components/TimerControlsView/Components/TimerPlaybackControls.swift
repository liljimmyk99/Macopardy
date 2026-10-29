import SwiftUI

extension TimerControlsView {
    func timerPlaybackControls() -> some View {
        HStack(spacing: 6) {
            Button("control.timer.adjustment.minus_5") {
                gameState.timer.addSeconds(-5)
            }
            .help(shortcutHelp("menu.game.timer.minus_5", .timerMinus5))

            if gameState.timer.isRunning {
                iconButton(
                    "pause.fill",
                    label: "control.timer.pause",
                    shortcut: .toggleTimer
                ) {
                    gameState.timer.stop()
                }
            } else {
                iconButton(
                    "play.fill",
                    label: "control.timer.start",
                    shortcut: .toggleTimer
                ) {
                    gameState.timer.start()
                }
            }

            iconButton(
                "arrow.counterclockwise",
                label: "control.timer.reset",
                shortcut: .resetTimer
            ) {
                gameState.timer.reset()
            }

            Button("control.timer.adjustment.plus_5") {
                gameState.timer.addSeconds(5)
            }
            .help(shortcutHelp("menu.game.timer.plus_5", .timerPlus5))
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }

    private func iconButton(
        _ systemImage: String,
        label: LocalizedStringKey,
        shortcut: AppShortcut,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: 28)
        }
        .accessibilityLabel(Text(label))
        .help(Text(label) + Text(verbatim: " (\(shortcut.glyph))"))
    }

    private func shortcutHelp(_ title: LocalizedStringKey, _ shortcut: AppShortcut) -> Text {
        Text(title) + Text(verbatim: " (\(shortcut.glyph))")
    }
}
