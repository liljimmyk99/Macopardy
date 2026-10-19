//
//  ControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct ControlView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            ScrollView {
                detailContent
            }
            .navigationTitle(navigationTitleText)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Text(phaseIndicator)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(MacpardyTheme.gold.opacity(0.2))
                        .foregroundStyle(MacpardyTheme.gold)
                        .clipShape(Capsule())
                }
            }
        }
        .background(MacpardyTheme.controlBackground)
    }
}

#Preview {
    ControlView()
        .environment(GameState())
        .frame(width: 1200, height: 900)
}
