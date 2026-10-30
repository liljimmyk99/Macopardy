//
//  ScoreControlsView.swift
//  Macpardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct ScoreControlsView: View {

    @Environment(GameState.self) var gameState
    @Environment(BuzzerState.self) var buzzerState

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
        .environment(BuzzerState())
        .padding()
        .frame(width: 500)
}
