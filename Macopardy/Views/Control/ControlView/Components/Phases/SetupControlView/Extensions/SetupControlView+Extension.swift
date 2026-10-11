import SwiftUI

extension SetupControlView {
    func setupHeader() -> some View {
        VStack(spacing: 8) {
            Text("Phase 1: Game Setup")
                .font(.title2.bold())

            Text("Configure your teams before starting the game.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 10)
    }

    func startGameButton() -> some View {
        LargeButton(
            title: "Start Game",
            systemImage: "play.circle.fill",
            tint: .green
        ) {
            gameState.startGame()
        }
        .frame(maxWidth: 300)
        .padding(.top, 8)
    }
}
