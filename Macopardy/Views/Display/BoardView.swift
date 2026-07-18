//
//  BoardView.swift
//  Macopardy
//

import SwiftUI

struct BoardView: View {

    let board: JeopardyBoard

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                ForEach(board.categories) { category in
                    CategoryColumnView(category: category)
                }
            }
            .padding(8)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(JeopardyTheme.boardBlue)
    }
}

#Preview {
    BoardView(board: JeopardyBoard.sample)
        .frame(width: 960, height: 540)
}
