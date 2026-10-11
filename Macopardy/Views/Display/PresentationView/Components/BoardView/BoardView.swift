import SwiftUI

struct BoardView: View {

    let board: JeopardyBoard

    var body: some View {
        GeometryReader { geometry in
            boardGrid(size: geometry.size)
        }
        .background(JeopardyTheme.boardBlue)
    }
}

#Preview {
    BoardView(board: JeopardyBoard.sample)
        .frame(width: 960, height: 540)
}
