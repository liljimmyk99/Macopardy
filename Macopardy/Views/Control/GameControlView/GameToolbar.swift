//
//  GameToolbar.swift
//  Macopardy
//

import SwiftUI

struct GameToolbar: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(GameState.self) private var gameState

    var body: some View {
        HStack(spacing: 12) {
            LargeButton(title: "Reveal Answer", systemImage: "eye") {
                gameState.revealAnswer()
            }

            LargeButton(title: "Show Board", systemImage: "square.grid.3x3") {
                openWindow(id: "display")
                gameState.showBoard()
            }

            LargeButton(title: "Daily Double", systemImage: "star.fill", tint: JeopardyTheme.gold) {
                gameState.showDailyDouble()
            }

            LargeButton(title: "Final Jeopardy", systemImage: "flag.checkered") {
                gameState.showFinalJeopardy(categoryTitle: "Think Music")
            }

            LargeButton(title: "Next Round", systemImage: "forward.fill") {
                gameState.advanceRound()
            }

            Spacer()

            if let board = gameState.game.currentBoard {
                Text(board.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    GameToolbar()
        .environment(GameState())
        .padding()
}
