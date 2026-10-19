import SwiftUI

struct QuestionTileView: View {

    let question: Question

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
