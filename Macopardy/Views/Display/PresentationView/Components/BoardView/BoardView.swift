import SwiftUI

struct BoardView: View {

    @Environment(GameState.self) var gameState
    @Environment(\.animationsEnabled) var animationsEnabled

    let board: MacpardyBoard

    /// Set once the intro starts; until then it follows `gameState`, so the
    /// first frame already hides what the intro is about to reveal.
    @State var introReveal: BoardReveal?

    var body: some View {
        GeometryReader { geometry in
            boardGrid(size: geometry.size)
        }
        .background(MacpardyTheme.boardBlue)
        .task { await playIntro() }
    }
}

#Preview {
    BoardView(board: MacpardyBoard.sample)
        .environment(GameState())
        .frame(width: 960, height: 540)
}
