import SwiftUI

extension ScoreboardView {
    func scoreboardContent() -> some View {
        HStack(spacing: 32) {
            ForEach(teams) { team in
                TeamScoreView(team: team)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background(JeopardyTheme.boardBlue.opacity(0.95))
    }
}
