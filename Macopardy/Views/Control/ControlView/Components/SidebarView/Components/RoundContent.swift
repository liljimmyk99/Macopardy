//
//  RoundContent.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//
import SwiftUI

extension SidebarView {
    
    @ViewBuilder
    func roundContent() -> some View {
        if let board = gameState.game.currentBoard {
            Label(board.title, systemImage: "rectangle.grid.3x2")
            Text(board.round.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            Text("No Active Round")
                .foregroundStyle(.secondary)
        }
    }
}
