//
//  BuiltInGamePicker.swift
//  Macopardy
//
//  Lists the games that ship with the app, with "Load my own file…" below.
//

import SwiftUI

struct BuiltInGamePicker: View {

    let title: LocalizedStringKey
    let games: [BundledGame]
    let onSelect: (BundledGame) -> Void
    let onLoadOwnFile: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2.bold())

            VStack(spacing: 8) {
                ForEach(games) { game in
                    Button {
                        onSelect(game)
                    } label: {
                        Text(verbatim: game.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 6)
                    }
                    .controlSize(.large)
                }

                Button(action: onLoadOwnFile) {
                    Label("launch.picker.load_own_file", systemImage: "folder")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                }
                .controlSize(.large)
            }

            HStack {
                Spacer()
                Button("common.cancel", role: .cancel, action: onCancel)
                    .keyboardShortcut(.cancelAction)
            }
        }
        .padding(24)
        .frame(width: 420)
    }
}

#Preview {
    BuiltInGamePicker(
        title: "launch.picker.play_title",
        games: [BundledGame(id: "a.json", title: "Classic Game 1")],
        onSelect: { _ in },
        onLoadOwnFile: {},
        onCancel: {}
    )
}
