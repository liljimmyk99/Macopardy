//
//  TeamEditorView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct TeamEditorView: View {

    @Environment(GameState.self) var gameState

    let colorOptions = ["blue", "red", "green", "yellow", "purple", "orange"]

    var body: some View {
        GroupBox {
            teamEditorContent()
        } label: {
            teamEditorHeader()
        }
    }
}

#Preview {
    TeamEditorView()
        .environment(GameState())
        .padding()
        .frame(width: 500)
}
