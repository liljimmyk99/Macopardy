//
//  ShortcutCatalogTests.swift
//  MacopardyTests
//

import SwiftUI
import XCTest
@testable import Macopardy

@MainActor
final class ShortcutCatalogTests: XCTestCase {

    private struct Combo: Hashable {
        let character: Character
        let modifiers: Int

        init(character: Character, modifiers: EventModifiers) {
            self.character = character
            self.modifiers = modifiers.rawValue
        }
    }

    private func combo(_ shortcut: AppShortcut) -> Combo {
        Combo(character: shortcut.key.character, modifiers: shortcut.modifiers)
    }

    func testNoTwoShortcutsShareAKeyCombination() {
        var seen: [Combo: AppShortcut] = [:]
        for shortcut in AppShortcut.allCases {
            let combo = combo(shortcut)
            if let other = seen[combo] {
                XCTFail("\(shortcut) and \(other) both use \(shortcut.glyph)")
            }
            seen[combo] = shortcut
        }
    }

    func testNoShortcutUsesAReservedSystemCombination() {
        let reserved: [Combo] = [
            Combo(character: "q", modifiers: .command),
            Combo(character: "h", modifiers: .command),
            Combo(character: "m", modifiers: .command),
            Combo(character: "w", modifiers: .command),
            Combo(character: ",", modifiers: .command),
            Combo(character: "f", modifiers: [.control, .command]),
            Combo(character: "z", modifiers: .command),
            Combo(character: "z", modifiers: [.shift, .command]),
            Combo(character: "c", modifiers: .command),
            Combo(character: "v", modifiers: .command),
            Combo(character: "x", modifiers: .command),
            Combo(character: "a", modifiers: .command),
        ]
        for shortcut in AppShortcut.allCases {
            XCTAssertFalse(reserved.contains(combo(shortcut)), "\(shortcut) uses a reserved shortcut")
        }
    }

    func testEveryTitleIsLocalized() {
        let bundle = Bundle(for: GameState.self)
        for shortcut in AppShortcut.allCases {
            let value = bundle.localizedString(forKey: shortcut.titleKey, value: "__missing__", table: nil)
            XCTAssertNotEqual(value, "__missing__", "\(shortcut.titleKey) is missing from Localizable.xcstrings")
        }
    }

    func testGlyphOrdersModifiersAndNamesArrows() {
        XCTAssertEqual(AppShortcut.buzzers.glyph, "⇧⌘B")
        XCTAssertEqual(AppShortcut.nextRound.glyph, "⌘→")
        XCTAssertEqual(AppShortcut.resetTimer.glyph, "⌘←")
        XCTAssertEqual(AppShortcut.toggleTimer.glyph, "⌘T")
    }
}
