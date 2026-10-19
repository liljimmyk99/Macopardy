import SwiftUI

extension PresentationView {
    func setupPhaseContent() -> some View {
        VStack(spacing: 20) {
            Spacer()
            GameTitleView(title: "Jeopardy!")
            Text("display.setup.waiting")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(JeopardyTheme.boardBlue)
    }
}
