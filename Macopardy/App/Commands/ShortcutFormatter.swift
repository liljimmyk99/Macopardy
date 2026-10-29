//
//  ShortcutFormatter.swift
//  Macopardy
//
//  Draws a key and its modifiers the way macOS menus do, e.g. "⇧⌘B".
//

import SwiftUI

nonisolated enum ShortcutFormatter {

    static func glyph(key: KeyEquivalent, modifiers: EventModifiers) -> String {
        var text = ""
        // macOS order: control, option, shift, command.
        if modifiers.contains(.control) { text += "⌃" }
        if modifiers.contains(.option) { text += "⌥" }
        if modifiers.contains(.shift) { text += "⇧" }
        if modifiers.contains(.command) { text += "⌘" }
        return text + keyGlyph(key)
    }

    static func keyGlyph(_ key: KeyEquivalent) -> String {
        switch key {
        case .leftArrow: "←"
        case .rightArrow: "→"
        case .upArrow: "↑"
        case .downArrow: "↓"
        case .escape: "⎋"
        case .return: "↩"
        case .delete: "⌫"
        case .tab: "⇥"
        case .space: "Space"
        case "-": "−"
        default: String(key.character).uppercased()
        }
    }
}
