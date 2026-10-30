//
//  GameStateUndoTests.swift
//  MacopardyTests
//

import XCTest
@testable import Macopardy

@MainActor
final class GameStateUndoTests: XCTestCase {

    private var state: GameState!
    private var manager: UndoManager!
    private var teamID: UUID!

    override func setUp() {
        state = GameState()
        manager = UndoManager()
        manager.groupsByEvent = false
        state.scoreUndoManager = manager
        teamID = state.game.teams[0].id
    }

    private var score: Int { state.game.teams[0].score }

    /// Runs `change` as one undo group, like one click.
    private func step(_ change: () -> Void) {
        manager.beginUndoGrouping()
        change()
        manager.endUndoGrouping()
    }

    func testAwardUndoRedo() {
        step { state.adjustScore(for: teamID, by: 400) }
        XCTAssertEqual(score, 400)
        XCTAssertEqual(manager.undoActionName, "Award Points")

        manager.undo()
        XCTAssertEqual(score, 0)
        XCTAssertEqual(manager.redoActionName, "Award Points")

        manager.redo()
        XCTAssertEqual(score, 400)
    }

    func testDeductIsNamedDeductPoints() {
        step { state.adjustScore(for: teamID, by: -200) }
        XCTAssertEqual(manager.undoActionName, "Deduct Points")
        manager.undo()
        XCTAssertEqual(score, 0)
    }

    func testResetScoreIsUndoable() {
        step { state.adjustScore(for: teamID, by: 600) }
        step { state.resetScore(for: teamID) }
        XCTAssertEqual(score, 0)
        XCTAssertEqual(manager.undoActionName, "Reset Score")

        manager.undo()
        XCTAssertEqual(score, 600)
    }

    func testUndoAndRedoSaveTheGame() {
        state.phase = .board // nothing is saved during setup
        step { state.adjustScore(for: teamID, by: 100) }
        var savedScores: [Int] = []
        state.onSaveTriggered = { savedScores.append($0.game.teams[0].score) }

        manager.undo()
        manager.redo()
        XCTAssertEqual(savedScores, [0, 100])
    }

    func testNoChangeRegistersNothing() {
        state.adjustScore(for: teamID, by: 0)
        XCTAssertFalse(manager.canUndo)
    }

    func testAdvancingARoundClearsTheStack() {
        step { state.adjustScore(for: teamID, by: 100) }
        state.advanceRound()
        XCTAssertFalse(manager.canUndo)
    }

    func testLoadingAGameClearsTheStack() {
        step { state.adjustScore(for: teamID, by: 100) }
        state.loadGame(boards: [.sample])
        XCTAssertFalse(manager.canUndo)
    }

    func testRestoringAGameClearsTheStack() {
        step { state.adjustScore(for: teamID, by: 100) }
        state.restore(from: GameSnapshot(from: state))
        XCTAssertFalse(manager.canUndo)
    }
}
