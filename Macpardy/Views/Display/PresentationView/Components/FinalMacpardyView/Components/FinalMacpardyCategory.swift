import SwiftUI

extension FinalMacpardyView {
    @ViewBuilder
    func finalMacpardyCategory() -> some View {
        if let categoryTitle = gameState.currentCategoryTitle {
            VStack(spacing: 8) {
                Text("display.final_macpardy.category_label")
                    .font(.headline)
                    .foregroundStyle(MacpardyTheme.gold.opacity(0.8))

                Text(categoryTitle.uppercased())
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
