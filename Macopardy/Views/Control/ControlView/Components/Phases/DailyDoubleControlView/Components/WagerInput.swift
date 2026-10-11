import SwiftUI

extension DailyDoubleControlView {
    @ViewBuilder
    func wagerInput() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Wager Amount:")
                    .font(.headline)
                Spacer()
                Text("Max Allowed: $\(maxWager)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("$")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)

                TextField("Wager", text: $wagerText)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3.monospacedDigit())
            }

            quickWagerButtons()
        }
    }
}
