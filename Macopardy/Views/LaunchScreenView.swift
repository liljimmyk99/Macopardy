//
//  LaunchScreenView.swift
//  Macopardy
//

import SwiftUI

struct LaunchScreenView: View {

    @Environment(\.openWindow) private var openWindow

    @Binding var hasSelectedGame: Bool
    @Binding var gameState: GameState

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                GameTitleView(title: "Jeopardy!")
                Text("Welcome to Macopardy")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)

            VStack(spacing: 16) {
                LargeButton(
                    title: "Open Existing Game",
                    systemImage: "folder.open"
                ) {
                    hasSelectedGame = true
                    
                }

                LargeButton(
                    title: "New Game",
                    systemImage: "plus.circle",
                    tint: .orange
                ) {
                    openWindow(id: "create-jeopardy")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.controlBackgroundColor))
    }
}

#Preview {
    LaunchScreenView(
        hasSelectedGame: .constant(false),
        gameState: .constant(GameState())
    )
}
