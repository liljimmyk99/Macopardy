//
//  ViewsContent.swift
//  Macopardy
//
import SwiftUI

extension SidebarView {

    @ViewBuilder
    func viewsContent() -> some View {
        Label {
            Text("control.sidebar.game")
                .fontWeight(.medium)
        } icon: {
            Image(systemName: phaseIcon)
                .foregroundStyle(MacpardyTheme.gold)
        }
        .tag(SidebarSelection.game)

        HStack {
            Label {
                Text("control.sidebar.buzzer")
                    .fontWeight(.medium)
            } icon: {
                Image(systemName: "iphone.gen3")
                    .foregroundStyle(MacpardyTheme.gold)
            }

            Spacer()

            if !buzzerState.disconnectedTeamIDs.isEmpty {
                Image(systemName: "iphone.slash")
                    .foregroundStyle(.orange)
                    .help("control.team.disconnected")
            } else if buzzerState.connectedClientCount > 0 {
                Text("\(buzzerState.connectedClientCount)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .tag(SidebarSelection.buzzer)
    }
}
