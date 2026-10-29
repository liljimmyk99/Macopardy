//
//  ShortcutCatalog.swift
//  Macopardy
//
//  Every keyboard shortcut in the app, defined once. Menu items and buttons
//  read their key from here so two actions can't claim the same one.
//

import SwiftUI

/// Where in the app a shortcut applies.
nonisolated enum ShortcutArea: String, CaseIterable {
    case start, file, edit, game, timer, editor, view, window, help
}

nonisolated enum AppShortcut: String, CaseIterable, Identifiable {

    // Start screen
    case play, newBoard, editBoard
    // Editor
    case saveGame
    // Game
    case returnToBoard, nextRound, finalMacpardy, revealAnswer, showDisplay, buzzers
    // Timer
    case toggleTimer, resetTimer, timerMinus5, timerPlus5

    var id: String { rawValue }

    /// Localization key of the action's title.
    var titleKey: String {
        switch self {
        case .play: "launch.tile.play"
        case .newBoard: "launch.tile.new"
        case .editBoard: "launch.tile.edit"
        case .saveGame: "create.button.save_game"
        case .returnToBoard: "control.question.button.return_to_board"
        case .nextRound: "control.board.button.next_round"
        case .finalMacpardy: "round.final_macpardy"
        case .revealAnswer: "control.question.button.reveal_answer"
        case .showDisplay: "control.toolbar.show_display"
        case .buzzers: "menu.game.buzzers"
        case .toggleTimer: "menu.game.timer.toggle"
        case .resetTimer: "menu.game.timer.reset"
        case .timerMinus5: "menu.game.timer.minus_5"
        case .timerPlus5: "menu.game.timer.plus_5"
        }
    }

    var key: KeyEquivalent {
        switch self {
        case .play: "o"
        case .newBoard: "n"
        case .editBoard: "e"
        case .saveGame: "s"
        case .returnToBoard, .buzzers: "b"
        case .nextRound: .rightArrow
        case .finalMacpardy: "f"
        case .revealAnswer: "r"
        case .showDisplay: "d"
        case .toggleTimer: "t"
        case .resetTimer: .leftArrow
        case .timerMinus5: "-"
        case .timerPlus5: "+"
        }
    }

    var modifiers: EventModifiers {
        switch self {
        case .buzzers: [.command, .shift]
        default: .command
        }
    }

    var area: ShortcutArea {
        switch self {
        case .play, .newBoard, .editBoard: .start
        case .saveGame: .editor
        case .returnToBoard, .nextRound, .finalMacpardy, .revealAnswer, .showDisplay, .buzzers: .game
        case .toggleTimer, .resetTimer, .timerMinus5, .timerPlus5: .timer
        }
    }

    /// The shortcut as menus draw it, e.g. "⇧⌘B".
    var glyph: String {
        var text = ""
        if modifiers.contains(.control) { text += "⌃" }
        if modifiers.contains(.option) { text += "⌥" }
        if modifiers.contains(.shift) { text += "⇧" }
        if modifiers.contains(.command) { text += "⌘" }
        switch key {
        case .leftArrow: text += "←"
        case .rightArrow: text += "→"
        default: text += String(key.character).uppercased()
        }
        return text
    }
}

extension View {
    /// Binds a button or menu item to a shortcut from the catalog.
    func keyboardShortcut(_ shortcut: AppShortcut) -> some View {
        keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
    }
}
