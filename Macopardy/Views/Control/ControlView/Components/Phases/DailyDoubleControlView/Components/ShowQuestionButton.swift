import SwiftUI

extension DailyDoubleControlView {
    func showQuestionButton() -> some View {
        LargeButton(
            title: "control.daily_double.button.show_question",
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
