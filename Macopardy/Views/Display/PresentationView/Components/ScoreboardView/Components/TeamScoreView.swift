//
//  TeamScoreView.swift
//  Macopardy
//

import SwiftUI

struct TeamScoreView: View {

    let team: Team
    var compact: Bool = false
    var isDisconnected: Bool = false
    /// Set while this team is answering after buzzing in.
    var responseCountdown: ResponseCountdown?

    var body: some View {
        teamScoreContent()
    }
}

#Preview {
    TeamScoreView(team: Team.sampleTeams[0])
        .padding()
        .background(MacpardyTheme.boardBlue)
}
