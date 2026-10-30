//
//  HelpCommands.swift
//  Macopardy
//
//  The Help menu. Replaces the empty "Macopardy Help" item with the
//  Keyboard Shortcuts window.
//

import SwiftUI

struct HelpCommands: Commands {

    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .help) {
            Button("menu.help.keyboard_shortcuts") {
                openWindow(id: "shortcuts")
            }
            .keyboardShortcut(.keyboardShortcuts)
        }
    }
}
