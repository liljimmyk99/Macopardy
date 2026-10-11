//
//  TeamEditorView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct TeamEditorView: View {

    @Environment(GameState.self) private var gameState

    private let colorOptions = ["blue", "red", "green", "yellow", "purple", "orange"]

    var body: some View {
        GroupBox {
            VStack(spacing: 12) {
                ForEach(gameState.game.teams) { team in
                    teamRow(for: team)
                }

                HStack {
                    Button {
                        gameState.addTeam()
                    } label: {
                        Label("Add Team", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderless)
                    .tint(.accentColor)

                    Spacer()
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 4)
        } label: {
            HStack {
                Text("Teams")
                    .font(.headline)
                Spacer()
                Text("\(gameState.game.teams.count) Teams")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func teamRow(for team: Team) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(team.displayColor)
                .frame(width: 16, height: 16)

            TextField("Team name", text: Binding(
                get: {
                    gameState.game.teams.first(where: { $0.id == team.id })?.name ?? team.name
                },
                set: { newName in
                    if let index = gameState.game.teams.firstIndex(where: { $0.id == team.id }) {
                        gameState.game.teams[index].name = newName
                    }
                }
            ))
            .textFieldStyle(.roundedBorder)

            Picker("Color", selection: Binding(
                get: {
                    gameState.game.teams.first(where: { $0.id == team.id })?.color ?? team.color
                },
                set: { newColor in
                    if let index = gameState.game.teams.firstIndex(where: { $0.id == team.id }) {
                        gameState.game.teams[index].color = newColor
                    }
                }
            )) {
                ForEach(colorOptions, id: \.self) { color in
                    Text(color.capitalized).tag(color)
                }
            }
            .labelsHidden()
            .frame(width: 120)

            if gameState.game.teams.count > 1 {
                Button {
                    gameState.removeTeam(id: team.id)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .help("Delete Team")
            }
        }
    }
}

#Preview {
    TeamEditorView()
        .environment(GameState())
        .padding()
        .frame(width: 500)
}
