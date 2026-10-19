import SwiftUI

extension DailyDoubleView {
    func dailyDoubleTitle() -> some View {
        Text("display.daily_double.title")
            .font(JeopardyTheme.dailyDoubleFont)
            .foregroundStyle(JeopardyTheme.gold)
            .multilineTextAlignment(.center)
    }
}
