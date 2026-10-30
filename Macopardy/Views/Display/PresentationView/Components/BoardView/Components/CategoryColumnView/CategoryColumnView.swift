import SwiftUI

struct CategoryColumnView: View {

    let category: Category
    /// The board intro shows titles one by one, then the clues together.
    var isTitleShown = true
    var areCluesShown = true

    var body: some View {
        VStack(spacing: 4) {
            categoryHeader()
            questionTiles()
        }
    }
}

#Preview {
    CategoryColumnView(category: MacpardyBoard.sample.categories[0])
        .frame(width: 160)
        .padding()
        .background(MacpardyTheme.boardBlue)
}
