import SwiftUI

struct QuestionTileView: View {

    let question: Question
    /// False while the board intro is still to turn this tile over.
    var isRevealed = true
    /// The tile's row, which staggers the board intro.
    var row = 0

    var body: some View {
        tileContent()
    }
}

#Preview {
    HStack {
        QuestionTileView(question: Question(value: 400, clue: "Test", response: "Test"))
        QuestionTileView(
            question: Question(value: 400, clue: "Test", response: "Test", hasBeenPlayed: true)
        )
    }
    .frame(width: 300)
    .padding()
    .background(MacpardyTheme.boardBlue)
}
