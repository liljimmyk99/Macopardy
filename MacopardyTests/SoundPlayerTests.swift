//
//  SoundPlayerTests.swift
//  MacopardyTests
//

import XCTest
@testable import Macopardy

@MainActor
final class SoundPlayerTests: XCTestCase {

    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "SoundPlayerTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testEverySoundShipsInTheAppBundle() {
        for effect in SoundEffect.allCases {
            XCTAssertNotNil(
                Bundle.main.url(forResource: effect.rawValue, withExtension: effect.fileExtension),
                "missing \(effect.rawValue).\(effect.fileExtension)"
            )
        }
    }

    func testSoundsAreOnByDefault() {
        let player = SoundPlayer(defaults: defaults)
        XCTAssertTrue(player.effectsEnabled)
        XCTAssertTrue(player.musicEnabled)
    }

    func testSwitchesAreRemembered() {
        let player = SoundPlayer(defaults: defaults)
        player.effectsEnabled = false
        player.musicEnabled = false

        let relaunched = SoundPlayer(defaults: defaults)
        XCTAssertFalse(relaunched.effectsEnabled)
        XCTAssertFalse(relaunched.musicEnabled)
    }

    func testMusicPlaysOnTheBoardOnly() {
        XCTAssertTrue(SoundCue.entering(.board).playsMusic)
        for phase in GamePhase.allCases where phase != .board {
            XCTAssertFalse(SoundCue.entering(phase).playsMusic, phase.rawValue)
        }
    }

    func testDailyDoubleAndFinalHaveTheirOwnSting() {
        XCTAssertEqual(SoundCue.entering(.dailyDouble).effect, .dailyDouble)
        XCTAssertEqual(SoundCue.entering(.finalMacpardyCategory).effect, .finalMacpardy)
    }

    func testOtherPhasesAreSilent() {
        let silent: [GamePhase] = [.setup, .board, .question, .answer, .finalMacpardyQuestion, .finalMacpardyAnswer]
        for phase in silent {
            XCTAssertNil(SoundCue.entering(phase).effect, phase.rawValue)
        }
    }
}
