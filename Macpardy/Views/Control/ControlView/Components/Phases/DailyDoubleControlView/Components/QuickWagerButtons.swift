import SwiftUI

extension DailyDoubleControlView {
    @ViewBuilder
    func quickWagerButtons() -> some View {
        HStack(spacing: 8) {
            Button("control.daily_double.quick_wager.min") {
                wagerText = "5"
            }
            .buttonStyle(.bordered)

            if let clueValue = gameState.currentQuestion?.value {
                Button("control.daily_double.quick_wager.clue_value \(clueValue)") {
                    wagerText = "\(clueValue)"
                }
                .buttonStyle(.bordered)
            }

            Button("control.daily_double.quick_wager.true_daily_double \(maxWager)") {
                wagerText = "\(maxWager)"
            }
            .buttonStyle(.bordered)
            .tint(MacpardyTheme.gold)
        }
    }
}
