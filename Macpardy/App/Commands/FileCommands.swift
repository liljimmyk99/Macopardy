//
//  FileCommands.swift
//  Macopardy
//
//  The File menu: New Board, Import Board… and Open Recent.
//

import SwiftUI

struct FileCommands: Commands {

    let coordinator: BoardOpenCoordinator

    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("menu.file.new_board") {
                openWindow(id: "create-macpardy")
            }
            .keyboardShortcut(.newBoard)

            Button("menu.file.import_board") {
                openWindow(id: "control")
                coordinator.requestImport()
            }
            .keyboardShortcut(.importBoard)

            Menu("menu.file.open_recent") {
                let urls = coordinator.recents.urls
                if urls.isEmpty {
                    Button("menu.file.no_recent_boards") {}
                        .disabled(true)
                } else {
                    ForEach(urls, id: \.self) { url in
                        Button(url.lastPathComponent) {
                            openWindow(id: "control")
                            coordinator.open(url: url)
                        }
                    }
                    Divider()
                    Button("menu.file.clear_menu") {
                        coordinator.recents.clear()
                    }
                }
            }
        }
    }
}
