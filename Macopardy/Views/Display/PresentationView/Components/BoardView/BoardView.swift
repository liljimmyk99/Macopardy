import SwiftUI

struct BoardView: View {

    let board: MacpardyBoard

    var body: some View {
        GeometryReader { geometry in
            boardGrid(size: geometry.size)
        }
        .background(MacpardyTheme.boardBlue)
    }
}

#Preview {
    BoardView(board: MacpardyBoard.sample)
        .frame(width: 960, height: 540)
}
