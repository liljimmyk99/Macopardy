//
//  SidebarView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct SidebarView: View {

    @Environment(GameState.self) var gameState
    @Environment(BuzzerState.self) var buzzerState

    @Binding var selection: SidebarSelection?

    var body: some View {
        List(selection: $selection) {
            Section("control.sidebar.section.views") {
                viewsContent()
            }

            Section("control.sidebar.section.round") {
                roundContent()
            }

            Section("control.sidebar.section.phase") {
                phaseContent()
            }

            Section("control.sidebar.section.teams") {
                teamStandingsContent()
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("control.sidebar.title")
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(selection: .constant(.game))
            .environment(GameState())
            .environment(BuzzerState())
    } detail: {
        Text("control.sidebar.detail_placeholder")
    }
}
