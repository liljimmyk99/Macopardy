//
//  BoardControlView.swift
//  Macpardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

/// The host's copy of the Display board: same layout, plus Daily Double and
/// picture markers only the host sees. Clicking a tile opens that clue.
struct BoardControlView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        if let board = gameState.game.currentBoard {
            boardGrid(board)
        } else {
            Text("control.board.no_board_available")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    let gameState = GameState()
    gameState.loadGame(boards: [MacpardyBoard.sample])

    return BoardControlView()
        .environment(gameState)
        .background(MacpardyTheme.boardBlue)
        .frame(width: 1100, height: 640)
}
