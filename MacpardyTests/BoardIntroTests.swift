//
//  BoardIntroTests.swift
//  MacopardyTests
//

import XCTest
@testable import Macopardy

@MainActor
final class BoardIntroTests: XCTestCase {

    func testIntroStartsWithTheGameAndEndsWithTheFirstClue() throws {
        let state = GameState()
        XCTAssertFalse(state.boardIntroPending)

        state.startGame()
        XCTAssertTrue(state.boardIntroPending)

        let category = try XCTUnwrap(state.game.currentBoard?.categories.first)
        let question = try XCTUnwrap(category.questions.first { !$0.isDailyDouble })
        state.selectQuestion(question, categoryTitle: category.title)
        XCTAssertFalse(state.boardIntroPending)

        state.showBoard()
        XCTAssertFalse(state.boardIntroPending, "returning from a clue doesn't replay the intro")
    }

    func testAdvancingRoundPlaysIntroAgain() {
        let state = GameState(rounds: [MacpardyBoard.sample, MacpardyBoard.sample])
        state.startGame()
        state.boardIntroPending = false

        state.advanceRound()
        XCTAssertEqual(state.game.currentRound, 1)
        XCTAssertTrue(state.boardIntroPending)
    }
}
