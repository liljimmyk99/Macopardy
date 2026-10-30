//
//  UnfilledFieldTests.swift
//  MacpardyTests
//

import XCTest
@testable import Macpardy

@MainActor
final class UnfilledFieldTests: XCTestCase {

    func testUntouchedDraftHasEveryFieldUnfilled() {
        // game title + 2 round titles + 12 categories + 60 clues + 60 answers + 3 final
        XCTAssertEqual(BoardDefaults.makeDraft().unfilledFields().count, 1 + 2 + 12 + 60 + 60 + 3)
    }

    func testEditingAFieldClearsItAndRevertingBringsItBack() {
        var draft = BoardDefaults.makeDraft()
        let all = draft.unfilledFields().count

        draft.title = "Trivia Night"
        XCTAssertEqual(draft.unfilledFields().count, all - 1)
        XCTAssertFalse(draft.unfilledFields().contains(.gameTitle))

        draft.title = BoardDefaults.gameTitle
        XCTAssertEqual(draft.unfilledFields().count, all)
    }

    func testWhitespaceIsIgnoredAndEmptyCounts() {
        var draft = BoardDefaults.makeDraft()
        draft.title = "Real"
        XCTAssertFalse(draft.unfilledFields().contains(.gameTitle))

        draft.title = "  \(BoardDefaults.gameTitle)\n"
        XCTAssertTrue(draft.unfilledFields().contains(.gameTitle))

        draft.title = "   "
        XCTAssertTrue(draft.unfilledFields().contains(.gameTitle))
    }

    func testClueAndAnswerAreTrackedSeparately() {
        var draft = BoardDefaults.makeDraft()
        draft.round2Categories[3].questions[1].clue = "What is a clue?"

        let fields = draft.unfilledFields()
        XCTAssertFalse(fields.contains(.clue, round: 1, category: 3, row: 1))
        XCTAssertTrue(fields.contains(.answer, round: 1, category: 3, row: 1))
        XCTAssertTrue(fields.contains(.clue, round: 0, category: 3, row: 1))
    }

    func testFinalFields() {
        var draft = BoardDefaults.makeDraft()
        draft.finalMacpardy = DraftFinalMacpardy(category: "Rivers", clue: "Longest river", response: "")
        let fields = draft.unfilledFields()
        XCTAssertFalse(fields.contains(.finalCategory, round: 2))
        XCTAssertFalse(fields.contains(.finalClue, round: 2))
        XCTAssertTrue(fields.contains(.finalAnswer, round: 2))
    }

    func testLocationsAndGroupingNameTheRoundAndCategory() throws {
        let draft = BoardDefaults.makeDraft()
        let clue = try XCTUnwrap(draft.unfilledFields().first { $0.kind == .clue && $0.round == 1 && $0.category == 1 && $0.row == 2 })
        XCTAssertEqual(clue.location, "Round 2, category 2, $1200 clue")
        XCTAssertEqual(clue.area, "Round 2, category 2")

        let groups = draft.unfilledFields().groupedByArea
        // Game title, 2 round titles, 12 categories, and Final.
        XCTAssertEqual(groups.count, 1 + 2 + 12 + 1)
        XCTAssertEqual(groups.first { $0.area == "Round 1, category 1" }?.count, 1 + 5 + 5)
    }

    func testPerRoundCounts() {
        let fields = BoardDefaults.makeDraft().unfilledFields()
        XCTAssertEqual(fields.fieldCount(inRound: 2), 3)
        XCTAssertEqual(fields.fieldCount(inRound: 0), 1 + 6 + 60)
    }
}
