//
//  FinalMacpardyCategoryControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct FinalMacpardyCategoryControlView: View {

    @Environment(GameState.self) var gameState
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
    }
}

#Preview {
    let gameState = GameState()
    gameState.showFinalMacpardy(categoryTitle: "Think Music")

    return FinalMacpardyCategoryControlView()
        .environment(gameState)
}
