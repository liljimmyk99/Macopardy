//
//  DisplayTeamConnectionRow.swift
//  Macopardy
//
//  One chip per team on the Display's setup screen showing whether a phone
//  has joined as that team yet.
//

import SwiftUI

struct DisplayTeamConnectionRow: View {

    let teams: [Team]
    let connectedTeamIDs: Set<UUID>

    var body: some View {
        HStack(spacing: 20) {
            ForEach(teams) { team in
                teamChip(team, isConnected: connectedTeamIDs.contains(team.id))
            }
        }
    }

    private func teamChip(_ team: Team, isConnected: Bool) -> some View {
        VStack(spacing: 10) {
            Text(team.name)
                .font(.title2.weight(.semibold))
                .foregroundStyle(team.displayColor)
                .lineLimit(1)

            Label(
                isConnected ? "display.setup.team.connected" : "display.setup.team.not_connected",
                systemImage: isConnected ? "checkmark.circle.fill" : "iphone.slash"
            )
            .font(.title3.weight(.medium))
            .foregroundStyle(isConnected ? .green : MacpardyTheme.mutedText)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .frame(minWidth: 200)
        .background(MacpardyTheme.panelBlue, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isConnected ? team.displayColor : .white.opacity(0.15), lineWidth: isConnected ? 3 : 1)
        }
        .opacity(isConnected ? 1 : 0.75)
        .animation(.easeInOut(duration: 0.25), value: isConnected)
    }
}

#Preview {
    DisplayTeamConnectionRow(teams: Team.sampleTeams, connectedTeamIDs: [Team.sampleTeams[0].id])
        .padding()
        .background(MacpardyTheme.boardBlue)
}
