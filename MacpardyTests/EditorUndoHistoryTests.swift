//
//  EditorUndoHistoryTests.swift
//  MacopardyTests
//

import XCTest
@testable import Macopardy

@MainActor
final class EditorUndoHistoryTests: XCTestCase {

    private let t0 = Date(timeIntervalSince1970: 1_000)

    /// One draft per test: each call to `makeDraft()` gives its categories new ids.
    private lazy var start = BoardDefaults.makeDraft()

    private func base() -> BoardDraft { start }

    func testUnchangedDraftIsIgnored() {
        var history = EditorUndoHistory(draft: base())
        XCTAssertEqual(history.record(base(), at: t0), .ignore)
    }

    func testChangesAreNamedByWhatChanged() {
        let draft = base()
        func name(_ edit: (inout BoardDraft) -> Void) -> EditorChange.Kind {
            var changed = draft
            edit(&changed)
            return EditorChange.between(draft, changed).kind
        }
        XCTAssertEqual(name { $0.title += "x" }, .editTitle)
        XCTAssertEqual(name { $0.round2Title += "x" }, .renameRound)
        XCTAssertEqual(name { $0.round1Categories[0].title += "x" }, .editCategory)
        XCTAssertEqual(name { $0.round1Categories[1].questions[2].clue += "x" }, .editClue)
        XCTAssertEqual(name { $0.round1Categories[1].questions[2].response += "x" }, .editAnswer)
        XCTAssertEqual(name { $0.round2Values[0] += 100 }, .changeValue)
        XCTAssertEqual(name { $0.round1Categories[0].questions[0].isDailyDouble.toggle() }, .toggleDailyDouble)
        XCTAssertEqual(name { $0.round1Categories[0].questions[0].image = QuestionImage(path: "a.png", data: nil) }, .addImage)
        XCTAssertEqual(name { $0.finalMacpardy.clue += "x" }, .editClue)
    }

    func testRemovingAnImageIsNamedRemove() {
        var withImage = base()
        withImage.round1Categories[0].questions[0].image = QuestionImage(path: "a.png", data: nil)
        var without = withImage
        without.round1Categories[0].questions[0].image = nil
        XCTAssertEqual(EditorChange.between(withImage, without).kind, .removeImage)
    }

    func testTypingInOneFieldMergesIntoOneStep() {
        var history = EditorUndoHistory(draft: start)
        var draft = start
        draft.title = "A"
        guard case .newStep(let change, let before) = history.record(draft, at: t0) else {
            return XCTFail("expected a new step")
        }
        XCTAssertEqual(change.kind, .editTitle)
        XCTAssertEqual(before, start)

        draft.title = "AB"
        XCTAssertEqual(history.record(draft, at: t0.addingTimeInterval(0.5)), .merge)
        // The window is measured from the latest keystroke.
        draft.title = "ABC"
        XCTAssertEqual(history.record(draft, at: t0.addingTimeInterval(1.4)), .merge)
    }

    func testPauseStartsANewStep() {
        var history = EditorUndoHistory(draft: base())
        var draft = base()
        draft.title = "A"
        _ = history.record(draft, at: t0)
        draft.title = "AB"
        if case .newStep = history.record(draft, at: t0.addingTimeInterval(2)) {} else {
            XCTFail("expected a new step after a pause")
        }
    }

    func testDifferentFieldStartsANewStep() {
        var history = EditorUndoHistory(draft: base())
        var draft = base()
        draft.round1Categories[0].questions[0].clue += "x"
        _ = history.record(draft, at: t0)
        draft.round1Categories[0].questions[1].clue += "x"
        if case .newStep = history.record(draft, at: t0.addingTimeInterval(0.1)) {} else {
            XCTFail("a different clue is a different step")
        }
    }

    func testClosingTheStepStartsANewOne() {
        var history = EditorUndoHistory(draft: base())
        var draft = base()
        draft.title = "A"
        _ = history.record(draft, at: t0)
        history.closeStep()
        draft.title = "AB"
        if case .newStep = history.record(draft, at: t0.addingTimeInterval(0.1)) {} else {
            XCTFail("expected a new step")
        }
    }

    func testAppliedDraftIsNotRecordedAgain() {
        var history = EditorUndoHistory(draft: start)
        var draft = start
        draft.title = "A"
        _ = history.record(draft, at: t0)
        history.applied(start) // an undo put the old draft back
        XCTAssertEqual(history.record(start, at: t0.addingTimeInterval(0.1)), .ignore)
    }
}

@MainActor
final class EditorUndoControllerTests: XCTestCase {

    /// Stands in for the editor's fields.
    private final class FakeEditor {
        var draft = BoardDefaults.makeDraft()
    }

    private func makeController(for editor: FakeEditor) -> (EditorUndoController, UndoManager) {
        let manager = UndoManager()
        manager.groupsByEvent = false
        let controller = EditorUndoController(draft: editor.draft)
        controller.apply = { editor.draft = $0 }
        controller.reset(to: editor.draft, undoManager: manager)
        return (controller, manager)
    }

    /// Makes a change the way the editor does, then reports it.
    private func edit(
        _ editor: FakeEditor,
        _ controller: EditorUndoController,
        _ manager: UndoManager,
        _ change: (inout BoardDraft) -> Void
    ) {
        change(&editor.draft)
        manager.beginUndoGrouping()
        controller.draftChanged(editor.draft, undoManager: manager)
        manager.endUndoGrouping()
    }

    func testUndoThenRedoRestoresTheDraftAndNamesTheStep() {
        let editor = FakeEditor()
        let original = editor.draft
        let (controller, manager) = makeController(for: editor)

        edit(editor, controller, manager) { $0.round1Categories[0].questions[0].isDailyDouble.toggle() }
        let edited = editor.draft
        XCTAssertEqual(manager.undoActionName, "Toggle Daily Double")

        manager.undo()
        XCTAssertEqual(editor.draft, original)
        XCTAssertEqual(manager.redoActionName, "Toggle Daily Double")

        manager.redo()
        XCTAssertEqual(editor.draft, edited)
    }

    func testUndoDoesNotRecordItself() {
        let editor = FakeEditor()
        let (controller, manager) = makeController(for: editor)
        edit(editor, controller, manager) { $0.title = "New title" }

        manager.undo()
        // The editor reports the restored draft; it must not add a step.
        controller.draftChanged(editor.draft, undoManager: manager)
        XCTAssertFalse(manager.canUndo)
        XCTAssertTrue(manager.canRedo)
    }

    func testClearStackDropsEverything() {
        let editor = FakeEditor()
        let (controller, manager) = makeController(for: editor)
        edit(editor, controller, manager) { $0.title = "New title" }
        controller.clearStack()
        XCTAssertFalse(manager.canUndo)
    }

    func testResetStartsFromTheNewDraft() {
        let editor = FakeEditor()
        let (controller, manager) = makeController(for: editor)
        edit(editor, controller, manager) { $0.title = "New title" }

        var other = BoardDefaults.makeDraft()
        other.title = "Loaded board"
        editor.draft = other
        controller.reset(to: other, undoManager: manager)
        XCTAssertFalse(manager.canUndo)

        controller.draftChanged(other, undoManager: manager)
        XCTAssertFalse(manager.canUndo)
    }
}
