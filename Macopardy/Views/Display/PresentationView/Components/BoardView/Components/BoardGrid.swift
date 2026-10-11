import SwiftUI

extension BoardView {
    func boardGrid(size: CGSize) -> some View {
        HStack(spacing: 4) {
            ForEach(board.categories) { category in
                CategoryColumnView(category: category)
            }
        }
        .padding(8)
        .frame(width: size.width, height: size.height)
    }
}
