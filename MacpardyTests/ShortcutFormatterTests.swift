//
//  ShortcutFormatterTests.swift
//  MacopardyTests
//

import SwiftUI
import XCTest
@testable import Macopardy

@MainActor
final class ShortcutFormatterTests: XCTestCase {

    private func glyph(_ key: KeyEquivalent, _ modifiers: EventModifiers) -> String {
        ShortcutFormatter.glyph(key: key, modifiers: modifiers)
    }

    func testModifiersAreOrderedControlOptionShiftCommand() {
        XCTAssertEqual(glyph("a", [.command, .shift, .option, .control]), "⌃⌥⇧⌘A")
        XCTAssertEqual(glyph("f", [.command, .control]), "⌃⌘F")
        XCTAssertEqual(glyph("b", [.shift, .command]), "⇧⌘B")
    }

    func testArrowsAndMinusUseTheirSymbols() {
        XCTAssertEqual(glyph(.leftArrow, .command), "⌘←")
        XCTAssertEqual(glyph(.rightArrow, .command), "⌘→")
        XCTAssertEqual(glyph(.upArrow, .command), "⌘↑")
        XCTAssertEqual(glyph(.downArrow, .command), "⌘↓")
        XCTAssertEqual(glyph("-", .command), "⌘−")
        XCTAssertEqual(glyph("+", .command), "⌘+")
    }

    func testSpecialKeys() {
        XCTAssertEqual(glyph(.escape, []), "⎋")
        XCTAssertEqual(glyph(.return, []), "↩")
        XCTAssertEqual(glyph(.delete, .command), "⌘⌫")
        XCTAssertEqual(glyph(.tab, .shift), "⇧⇥")
        XCTAssertEqual(glyph(",", .command), "⌘,")
    }
}
