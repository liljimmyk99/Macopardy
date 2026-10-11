import SwiftUI

struct CategoryColumnView: View {

    let category: Category

    var body: some View {
        VStack(spacing: 4) {
            categoryHeader()
            questionTiles()
        }
    }
}

#Preview {
    CategoryColumnView(category: JeopardyBoard.sample.categories[0])
        .frame(width: 160)
        .padding()
        .background(JeopardyTheme.boardBlue)
}
