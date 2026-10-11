//
//  Phase2BoardControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct BoardControlView: View {

    @Environment(\.openWindow) private var openWindow
    @Environment(GameState.self) private var gameState

    var body: some View {
        VStack(spacing: 20) {
            // Action Bar with only the 4 allowed controls
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

            // Question Picker
            QuestionPickerView()

            Spacer()
        }
        .padding()
    }
}

#Preview {
    BoardControlView()
        .environment(GameState())
}
