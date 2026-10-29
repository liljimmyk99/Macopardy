import SwiftUI

struct ScoreboardView: View {

    let teams: [Team]
    var disconnectedTeamIDs: Set<UUID> = []
    /// The answering team's response time, shown as dots above its score.
    var responseCountdown: ResponseCountdown?

    var body: some View {
        scoreboardContent()
    }
}

#Preview {
    ScoreboardView(teams: Team.sampleTeams)
}

#Preview("Team answering") {
    let teams = Team.sampleTeams
    return ScoreboardView(
        teams: teams,
        responseCountdown: ResponseCountdown(teamID: teams[1].id, remainingTime: 3, totalTime: 5)
    )
}
