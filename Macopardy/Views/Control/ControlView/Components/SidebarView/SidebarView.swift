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
            Section("Round") {
                roundContent()
            }

            Section("Phase") {
                phaseContent()
            }

            Section("Teams & Standings") {
                teamStandingsContent()
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Control Panel")
    }
}

#Preview {
    NavigationSplitView {
        SidebarView()
            .environment(GameState())
    } detail: {
        Text("Detail")
    }
}
