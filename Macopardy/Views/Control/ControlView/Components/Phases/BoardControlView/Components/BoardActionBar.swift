import SwiftUI

extension BoardControlView {
    @ViewBuilder
    func boardActionBar() -> some View {
        HStack(spacing: 12) {
            LargeButton(title: "control.board.button.show_hide", systemImage: "display") {
                openWindow(id: "display")
                gameState.showBoard()
            }

            LargeButton(title: "round.final_macpardy", systemImage: "flag.checkered", tint: MacpardyTheme.gold) {
                gameState.showFinalMacpardy()
            }

            LargeButton(title: "control.board.button.next_round", systemImage: "forward.fill") {
                gameState.advanceRound()
            }

            Spacer()

            if let board = gameState.game.currentBoard {
                Text(board.title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
