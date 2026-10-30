import SwiftUI

extension QuestionView {
    @ViewBuilder
    func questionHeading(for question: Question) -> some View {
        if let categoryTitle = gameState.currentCategoryTitle {
            Text(categoryTitle.uppercased())
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(MacpardyTheme.gold)
        }

        QuestionValueView(value: question.value, font: .system(size: 48, weight: .bold))
    }
}
