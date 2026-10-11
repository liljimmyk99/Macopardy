import SwiftUI

extension BoardControlView {
    @ViewBuilder
    func boardActionBar() -> some View {
        HStack(spacing: 12) {
            LargeButton(title: "Show/Hide Board", systemImage: "display") {
                openWindow(id: "display")
                gameState.showBoard()
            }

            LargeButton(title: "Final Jeopardy", systemImage: "flag.checkered", tint: JeopardyTheme.gold) {
                gameState.showFinalJeopardy()
            }

            LargeButton(title: "Next Round", systemImage: "forward.fill") {
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
