import SwiftUI

extension PresentationView {
    func setupPhaseContent() -> some View {
        VStack(spacing: 32) {
            Spacer()
            GameTitleView(title: "Macpardy!")

            if buzzerState.isRunning, let url = buzzerState.serverURL, let baseURL = buzzerState.baseURL {
                DisplayBuzzerJoinPanel(joinURL: url, baseURL: baseURL, joinCode: buzzerState.joinCode)
                DisplayTeamConnectionRow(
                    teams: gameState.game.teams,
                    connectedTeamIDs: buzzerState.claimedTeamIDs
                )
            } else {
                Text("display.setup.waiting")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MacpardyTheme.boardBlue)
    }
}
