//
//  Phase1SetupControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct SetupControlView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Phase 1: Game Setup")
                    .font(.title2.bold())

                Text("Configure your teams before starting the game.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 10)

            TeamEditorView()
                .frame(maxWidth: 600)

            LargeButton(
                title: "Start Game",
                systemImage: "play.circle.fill",
                tint: .green
            ) {
                gameState.startGame()
            }
            .frame(maxWidth: 300)
            .padding(.top, 8)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SetupControlView()
        .environment(GameState())
}
