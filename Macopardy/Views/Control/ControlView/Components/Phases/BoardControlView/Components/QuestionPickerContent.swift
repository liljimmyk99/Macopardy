import SwiftUI

extension QuestionPickerView {
    @ViewBuilder
    func questionPickerContent() -> some View {
        if let board = gameState.game.currentBoard {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(board.categories) { category in
                        categorySection(category)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 400)
        } else {
            Text("No board available")
                .foregroundStyle(.secondary)
        }
    }
}
