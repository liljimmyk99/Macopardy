import SwiftUI

extension DailyDoubleControlView {
    @ViewBuilder
    func dailyDoubleHeader() -> some View {
        VStack(spacing: 8) {
            Text("DAILY DOUBLE!")
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(JeopardyTheme.gold)

            if let category = gameState.currentCategoryTitle {
                Text("Category: \(category)")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 10)
    }
}
