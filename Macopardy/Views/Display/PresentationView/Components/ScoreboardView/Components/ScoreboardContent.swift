import SwiftUI

extension ScoreboardView {
    func scoreboardContent() -> some View {
        HStack(spacing: 32) {
            ForEach(teams) { team in
                TeamScoreView(team: team, isDisconnected: disconnectedTeamIDs.contains(team.id))
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background(MacpardyTheme.boardBlue.opacity(0.95))
    }
}
