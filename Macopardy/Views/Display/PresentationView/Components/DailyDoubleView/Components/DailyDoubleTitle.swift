import SwiftUI

extension DailyDoubleView {
    func dailyDoubleTitle() -> some View {
        Text("display.daily_double.title")
            .font(MacpardyTheme.dailyDoubleFont)
            .foregroundStyle(MacpardyTheme.gold)
            .multilineTextAlignment(.center)
    }
}
