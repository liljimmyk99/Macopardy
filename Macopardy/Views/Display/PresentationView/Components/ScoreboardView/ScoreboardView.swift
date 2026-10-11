import SwiftUI

struct ScoreboardView: View {

    let teams: [Team]

    var body: some View {
        scoreboardContent()
    }
}

#Preview {
    ScoreboardView(teams: Team.sampleTeams)
}
