//
//  FinalWagerDefaultsTests.swift
//  MacpardyTests
//

import XCTest
@testable import Macpardy

@MainActor
final class FinalWagerDefaultsTests: XCTestCase {

    private func makeState() -> (GameState, Team, Team, Team) {
        let rich = Team(name: "Rich", score: 1200)
        let mid = Team(name: "Mid", score: 400)
        let broke = Team(name: "Broke", score: -200)
        let state = GameState(rounds: [MacpardyBoard.sample], teams: [rich, mid, broke])
        return (state, rich, mid, broke)
    }

    func testMissingWagersGoAllIn() {
        let (state, rich, mid, broke) = makeState()
        state.showFinalMacpardy()
        XCTAssertTrue(state.finalMacpardyWagers.isEmpty)
        state.revealFinalMacpardyQuestion()
        XCTAssertEqual(state.finalMacpardyWagers[rich.id], 1200)
        XCTAssertEqual(state.finalMacpardyWagers[mid.id], 400)
        XCTAssertEqual(state.finalMacpardyWagers[broke.id], 0)
        XCTAssertEqual(state.phase, .finalMacpardyQuestion)
    }

    func testExistingWagersAreKept() {
        let (state, rich, mid, _) = makeState()
        state.showFinalMacpardy()
        state.setFinalWager(teamID: rich.id, amount: 0)
        state.revealFinalMacpardyQuestion()
        XCTAssertEqual(state.finalMacpardyWagers[rich.id], 0)
        XCTAssertEqual(state.finalMacpardyWagers[mid.id], 400)
    }

    func testSetWagerClampsAndRejectsExcluded() {
        let (state, rich, _, broke) = makeState()
        XCTAssertEqual(state.setFinalWager(teamID: rich.id, amount: 5_000), 1200)
        XCTAssertEqual(state.setFinalWager(teamID: rich.id, amount: -5), 0)
        XCTAssertNil(state.setFinalWager(teamID: broke.id, amount: 10))
        XCTAssertNil(state.finalMacpardyWagers[broke.id])
    }

    func testWagerLimitsUseScores() {
        let (state, rich, _, broke) = makeState()
        XCTAssertEqual(state.finalWagerLimits[rich.id], 1200)
        XCTAssertEqual(state.finalWagerLimits[broke.id], 0)
    }
}
