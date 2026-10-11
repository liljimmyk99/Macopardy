import SwiftUI

extension DailyDoubleView {
    func dailyDoubleContent() -> some View {
        ZStack {
            JeopardyTheme.clueBackground
            dailyDoubleTitle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
