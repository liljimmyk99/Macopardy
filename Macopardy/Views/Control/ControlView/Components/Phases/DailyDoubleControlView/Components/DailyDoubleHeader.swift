import SwiftUI

extension DailyDoubleControlView {
    @ViewBuilder
    func dailyDoubleHeader() -> some View {
        VStack(spacing: 8) {
            Text("control.daily_double.heading")
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(JeopardyTheme.gold)

            if let category = gameState.currentCategoryTitle {
                Text("control.daily_double.label_category \(category)")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 10)
    }
}
