//
//  BuzzerTeamRow.swift
//  Macopardy
//
//  One team in the buzzer tab: phone status, Remove phone, and Re-add.
//

import SwiftUI

struct BuzzerTeamRow: View {

    @Environment(BuzzerState.self) var buzzerState

    let team: Team

    @State private var showsJoinInfo = false

    private var isConnected: Bool { buzzerState.claimedTeamIDs.contains(team.id) }
    private var isDisconnected: Bool { buzzerState.disconnectedTeamIDs.contains(team.id) }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(team.displayColor)
                .frame(width: 16, height: 16)

            Text(team.name)
                .font(.body.weight(.medium))

            Text("$\(team.score)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)

            Spacer()

            status

            if isConnected {
                Button {
                    Task { await buzzerState.removePhone(forTeam: team.id) }
                } label: {
                    Label("control.team.remove_phone", systemImage: "iphone.slash")
                }
                .help("control.team.remove_phone.help")
            } else {
                Button {
                    showsJoinInfo = true
                } label: {
                    Label("control.buzzer.re_add", systemImage: "iphone.badge.plus")
                }
                .popover(isPresented: $showsJoinInfo, arrowEdge: .bottom) {
                    VStack(spacing: 12) {
                        Text("control.buzzer.re_add.caption \(team.name)")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                        BuzzerJoinInfoView()
                    }
                    .padding()
                    .frame(width: 400)
                }
            }
        }
    }

    @ViewBuilder
    private var status: some View {
        if isConnected {
            Label("control.buzzer.team.connected", systemImage: "iphone.gen3")
                .font(.caption)
                .foregroundStyle(.green)
        } else if isDisconnected {
            Label("control.team.disconnected", systemImage: "iphone.slash")
                .font(.caption)
                .foregroundStyle(.orange)
        } else {
            Label("control.buzzer.team.waiting", systemImage: "iphone")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    BuzzerTeamRow(team: Team.sampleTeams[0])
        .environment(BuzzerState())
        .padding()
        .frame(width: 600)
}
