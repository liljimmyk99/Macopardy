import SwiftUI

extension SetupControlView {
    func setupHeader() -> some View {
        VStack(spacing: 8) {
            Text("control.setup.heading")
                .font(.title2.bold())

            Text("control.setup.subheading")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 10)
    }

    func startGameButton() -> some View {
        LargeButton(
            title: "control.setup.button.start_game",
            systemImage: "play.circle.fill",
            tint: .green
        ) {
            gameState.startGame()
        }
        .frame(maxWidth: 300)
        .padding(.top, 8)
    }
}
