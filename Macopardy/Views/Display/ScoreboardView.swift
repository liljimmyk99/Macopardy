//
//  ScoreboardView.swift
//  Macopardy
//

import SwiftUI

struct ScoreboardView: View {

    let teams: [Team]

    var body: some View {
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

#Preview {
    ScoreboardView(teams: Team.sampleTeams)
}
