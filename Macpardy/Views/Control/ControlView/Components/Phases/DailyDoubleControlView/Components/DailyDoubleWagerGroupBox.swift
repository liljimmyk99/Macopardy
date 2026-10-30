import SwiftUI

extension DailyDoubleControlView {
    @ViewBuilder
    func dailyDoubleWagerGroupBox() -> some View {
        GroupBox("control.daily_double.group_box_title") {
            VStack(spacing: 20) {
                teamSelectionPicker()
                wagerInput()
            }
            .padding()
        }
        .frame(maxWidth: 550)
    }
}
