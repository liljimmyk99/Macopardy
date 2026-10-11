import SwiftUI

extension DailyDoubleControlView {
    @ViewBuilder
    func quickWagerButtons() -> some View {
        HStack(spacing: 8) {
            Button("Min ($5)") {
                wagerText = "5"
            }
            .buttonStyle(.bordered)

            if let clueValue = gameState.currentQuestion?.value {
                Button("Clue Value ($\(clueValue))") {
                    wagerText = "\(clueValue)"
                }
                .buttonStyle(.bordered)
            }

            Button("True Daily Double ($\(maxWager))") {
                wagerText = "\(maxWager)"
            }
            .buttonStyle(.bordered)
            .tint(JeopardyTheme.gold)
        }
    }
}
