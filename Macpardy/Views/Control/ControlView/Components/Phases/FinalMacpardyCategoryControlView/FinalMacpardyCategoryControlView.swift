//
//  FinalMacpardyCategoryControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct FinalMacpardyCategoryControlView: View {

    @Environment(GameState.self) var gameState
    @Environment(BuzzerState.self) var buzzerState
    @State var wagers: [UUID: String] = [:]

    var body: some View {
        VStack(spacing: 24) {
            finalMacpardyHeader()
            teamWagerGroup()
            revealQuestionButton()
            Spacer()
        }
        .padding()
        .onAppear {
            syncWagersFromGameState()
        }
        // Wagers arriving from phones show up in the fields.
        .onChange(of: gameState.finalMacpardyWagers) { _, _ in
            syncWagersFromGameState()
        }
    }
}

#Preview {
    let gameState = GameState()
    gameState.showFinalMacpardy(categoryTitle: "Think Music")

    return FinalMacpardyCategoryControlView()
        .environment(gameState)
        .environment(BuzzerState())
}
