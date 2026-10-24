import SwiftUI

struct ScoreboardView: View {

    let teams: [Team]
    var disconnectedTeamIDs: Set<UUID> = []

    var body: some View {
        scoreboardContent()
    }
}

#Preview {
    ScoreboardView(teams: Team.sampleTeams)
}
