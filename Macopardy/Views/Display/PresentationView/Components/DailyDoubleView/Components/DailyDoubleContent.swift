import SwiftUI

extension DailyDoubleView {
    func dailyDoubleContent() -> some View {
        ZStack {
            MacpardyTheme.clueBackground
            dailyDoubleTitle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
