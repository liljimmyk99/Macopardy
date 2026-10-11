//
//  Phase1SetupControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct SetupControlView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        VStack(spacing: 24) {
            setupHeader()

            TeamEditorView()
                .frame(maxWidth: 600)

            startGameButton()

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
