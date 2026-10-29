//
//  BoardDefaultsTests.swift
//  MacopardyTests
//

import XCTest
@testable import Macopardy

@MainActor
final class BoardDefaultsTests: XCTestCase {

    func testDefaultTextFollowsTheIssueFormat() {
        XCTAssertEqual(BoardDefaults.gameTitle, "Untitled Game")
        XCTAssertEqual(BoardDefaults.roundTitle(round: 2), "Round 2")
        XCTAssertEqual(BoardDefaults.categoryTitle(3), "Category 3")
        XCTAssertEqual(BoardDefaults.clue(category: 2, value: 400), "Category 2 · $400 question")
        XCTAssertEqual(BoardDefaults.answer(category: 2, value: 400), "Category 2 · $400 answer")
        XCTAssertEqual(BoardDefaults.finalCategory, "Final Jeopardy Category")
        XCTAssertEqual(BoardDefaults.finalClue, "Final Jeopardy Question")
        XCTAssertEqual(BoardDefaults.finalAnswer, "Final Jeopardy Answer")
    }

    func testNewDraftIsAFullGridWithStandardValues() {
        let draft = BoardDefaults.makeDraft()
        XCTAssertEqual(draft.round1Categories.count, 6)
        XCTAssertEqual(draft.round2Categories.count, 6)
        XCTAssertTrue(draft.round1Categories.allSatisfy { $0.questions.map(\.value) == [200, 400, 600, 800, 1000] })
        XCTAssertTrue(draft.round2Categories.allSatisfy { $0.questions.map(\.value) == [400, 800, 1200, 1600, 2000] })
        XCTAssertEqual(draft.title, "Untitled Game")
        XCTAssertEqual(draft.round1Title, "Round 1")
        XCTAssertEqual(draft.round2Title, "Round 2")
    }

    func testDailyDoublesArePlacedInDifferentCategories() {
        let draft = BoardDefaults.makeDraft()
        func doubles(_ categories: [DraftCategory]) -> [Int] {
            categories.enumerated().flatMap { index, category in
                category.questions.filter(\.isDailyDouble).map { _ in index }
            }
        }
        XCTAssertEqual(doubles(draft.round1Categories).count, 1)
        let round2 = doubles(draft.round2Categories)
        XCTAssertEqual(round2.count, 2)
        XCTAssertEqual(Set(round2).count, 2)
    }

    func testNewDraftBuildsCompleteBoards() {
        let boards = BoardDefaults.makeDraft().makeBoards()
        XCTAssertEqual(boards.count, 3)
        let clues = boards.flatMap { $0.categories.flatMap(\.questions) }
        XCTAssertTrue(clues.allSatisfy { !$0.clue.isEmpty && !$0.response.isEmpty })
    }
}
