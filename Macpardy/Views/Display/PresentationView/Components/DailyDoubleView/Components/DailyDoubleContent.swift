import SwiftUI

extension DailyDoubleView {
    func dailyDoubleContent() -> some View {
        ZStack {
            MacpardyTheme.clueBackground
            if animationsEnabled {
                DailyDoubleFlash()
            }
            dailyDoubleTitle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A burst of gold that fades as the title lands.
private struct DailyDoubleFlash: View {

    @State private var flashed = false

    var body: some View {
        RadialGradient(
            colors: [MacpardyTheme.gold.opacity(0.7), .clear],
            center: .center,
            startRadius: 0,
            endRadius: 600
        )
        .opacity(flashed ? 0 : 1)
        .scaleEffect(flashed ? 1.6 : 0.4)
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { flashed = true }
        }
    }
}
