//
//  TeamEditorView.swift
//  Macopardy
//

import SwiftUI

struct TeamEditorView: View {

    @Environment(GameState.self) private var gameState

    private let colorOptions = ["blue", "red", "green", "yellow", "purple", "orange"]

    var body: some View {
        GroupBox("Teams") {
            VStack(spacing: 12) {
                ForEach(gameState.game.teams.indices, id: \.self) { index in
                    teamRow(at: index)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func teamRow(at index: Int) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(gameState.game.teams[index].displayColor)
                .frame(width: 16, height: 16)

            TextField("Team name", text: Binding(
                get: { gameState.game.teams[index].name },
                set: { gameState.game.teams[index].name = $0 }
            ))
            .textFieldStyle(.roundedBorder)

            Picker("Color", selection: Binding(
                get: { gameState.game.teams[index].color },
                set: { gameState.game.teams[index].color = $0 }
            )) {
                ForEach(colorOptions, id: \.self) { color in
                    Text(color.capitalized).tag(color)
                }
            }
            .labelsHidden()
            .frame(width: 120)

            Text("\(gameState.game.teams[index].score)")
                .font(.headline.monospacedDigit())
                .frame(width: 60, alignment: .trailing)
        }
    }
}

#Preview {
    TeamEditorView()
        .environment(GameState())
        .padding()
        .frame(width: 500)
}
