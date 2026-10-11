//
//  BoardControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct BoardControlView: View {

    @Environment(\.openWindow) var openWindow
    @Environment(GameState.self) var gameState

    var body: some View {
        VStack(spacing: 20) {
            boardActionBar()
            QuestionPickerView()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    BoardControlView()
        .environment(GameState())
}
