//
//  TeamStandingsContent.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//
import SwiftUI

extension SidebarView {
    
    @ViewBuilder
    func teamStandingsContent() -> some View {
        ForEach(gameState.game.teams) { team in
            teamcard(team: team)
        }
    }
    
    @ViewBuilder
    private func teamcard(team: Team) -> some View {
        HStack {
            Circle()
                .fill(team.displayColor)
                .frame(width: 10, height: 10)

            Text(team.name)
                .font(.body)

            if buzzerState.disconnectedTeamIDs.contains(team.id) {
                Image(systemName: "iphone.slash")
                    .foregroundStyle(.orange)
                    .help("control.team.disconnected")
            }

            Spacer()

            Text("$\(team.score)")
                .font(.subheadline.monospacedDigit())
                .fontWeight(.semibold)
        }
    }
}
