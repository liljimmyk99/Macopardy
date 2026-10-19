//
//  SidebarView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct SidebarView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        List {
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
        SidebarView()
            .environment(GameState())
    } detail: {
        Text("control.sidebar.detail_placeholder")
    }
}
