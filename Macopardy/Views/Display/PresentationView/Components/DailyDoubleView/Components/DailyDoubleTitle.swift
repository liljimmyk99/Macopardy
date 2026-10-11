import SwiftUI

extension DailyDoubleView {
    func dailyDoubleTitle() -> some View {
        Text("DAILY DOUBLE")
            .font(JeopardyTheme.dailyDoubleFont)
            .foregroundStyle(JeopardyTheme.gold)
            .multilineTextAlignment(.center)
    }
}
