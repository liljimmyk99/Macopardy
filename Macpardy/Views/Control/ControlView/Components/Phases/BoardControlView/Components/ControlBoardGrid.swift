import SwiftUI

extension BoardControlView {
    func boardGrid(_ board: MacpardyBoard) -> some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(board.categories) { category in
                VStack(spacing: 4) {
                    CategoryHeaderView(title: category.title, font: MacpardyTheme.controlCategoryFont)
                        .frame(height: 64)

                    ForEach(category.questions) { question in
                        ControlQuestionTile(question: question, categoryTitle: category.title) {
                            gameState.selectQuestion(question, categoryTitle: category.title)
                        }
                    }
                }
            }
        }
        .padding(8)
    }
}
