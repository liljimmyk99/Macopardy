import SwiftUI

extension DailyDoubleControlView {
    func showQuestionButton() -> some View {
        LargeButton(
            title: "Show Question",
            systemImage: "questionmark.circle.fill",
            tint: JeopardyTheme.gold
        ) {
            let teamID = selectedTeamID ?? gameState.game.teams.first?.id ?? UUID()
            let finalWager = max(5, min(parsedWagerValue, maxWager))
            gameState.submitDailyDoubleWager(teamID: teamID, wager: finalWager)
        }
        .frame(maxWidth: 300)
    }
}
