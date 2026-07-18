//
//  TeamScoreView.swift
//  Macopardy
//

import SwiftUI

struct TeamScoreView: View {

    let team: Team
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 4 : 8) {
            Text(team.name)
                .font(compact ? .headline : .title2)
                .fontWeight(.semibold)
                .foregroundStyle(team.displayColor)

            Text("\(team.score)")
                .font(compact ? JeopardyTheme.scoreFont : .system(size: 40, weight: .bold))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TeamScoreView(team: Team.sampleTeams[0])
        .padding()
        .background(JeopardyTheme.boardBlue)
}
