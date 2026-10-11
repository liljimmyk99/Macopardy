import SwiftUI

extension CountdownView {
    func countdownText() -> some View {
        Text("\(seconds)")
            .font(font)
            .foregroundStyle(color)
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.default, value: seconds)
    }
}
