import SwiftUI

extension FinalJeopardyView {
    @ViewBuilder
    func finalJeopardyCategory() -> some View {
        if let categoryTitle = gameState.currentCategoryTitle {
            VStack(spacing: 8) {
                Text("display.final_jeopardy.category_label")
                    .font(.headline)
                    .foregroundStyle(JeopardyTheme.gold.opacity(0.8))

                Text(categoryTitle.uppercased())
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
