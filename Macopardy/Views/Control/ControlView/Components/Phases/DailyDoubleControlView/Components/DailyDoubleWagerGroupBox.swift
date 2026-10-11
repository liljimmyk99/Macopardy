import SwiftUI

extension DailyDoubleControlView {
    @ViewBuilder
    func dailyDoubleWagerGroupBox() -> some View {
        GroupBox("Daily Double Wager") {
            VStack(spacing: 20) {
                teamSelectionPicker()
                wagerInput()
            }
            .padding()
        }
        .frame(maxWidth: 550)
    }
}
