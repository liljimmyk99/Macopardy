import SwiftUI

extension BoardView {
    func boardGrid(size: CGSize) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(board.categories.enumerated()), id: \.element.id) { index, category in
                CategoryColumnView(
                    category: category,
                    isTitleShown: index < reveal.categoriesShown,
                    areCluesShown: reveal.cluesShown
                )
            }
        }
        .padding(8)
        .frame(width: size.width, height: size.height)
    }
}
