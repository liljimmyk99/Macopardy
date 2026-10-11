//
//  ScoreControlsView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct ScoreControlsView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        GroupBox("Scores") {
            VStack(spacing: 16) {
                scoreContent()
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ScoreControlsView()
        .environment(GameState())
        .padding()
        .frame(width: 500)
}
