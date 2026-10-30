//
//  BoardOpenCoordinatorTests.swift
//  MacopardyTests
//

import XCTest
@testable import Macopardy

private final class MemoryRecentsStorage: RecentBoardsStorage {
    var urls: [URL] = []
    func load() -> [URL] { urls }
    func save(_ urls: [URL]) { self.urls = urls }
}

@MainActor
final class BoardOpenCoordinatorTests: XCTestCase {

    private var directory: URL!
    private var recents: RecentBoards!
    private var session: BoardEditorSession!
    private var coordinator: BoardOpenCoordinator!
    private var started: [[MacpardyBoard]] = []
    private var editorShown = 0

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        recents = RecentBoards(storage: MemoryRecentsStorage())
        session = BoardEditorSession()
        coordinator = BoardOpenCoordinator(recents: recents, editorSession: session)
        started = []
        editorShown = 0
        coordinator.startGame = { [unowned self] in started.append($0) }
        coordinator.showEditor = { [unowned self] in editorShown += 1 }
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private func boardFile(named name: String = "game.macpardy") throws -> URL {
        let url = directory.appendingPathComponent(name)
        try BoardPackage.write([.sample]).write(to: url)
        return url
    }

    /// A complete game that is valid to edit, copied from the built-in games.
    private func editableFile() throws -> URL {
        let source = try XCTUnwrap(BundledGameLibrary.bundledDirectory).appendingPathComponent("classic-game-1.json")
        let url = directory.appendingPathComponent("edit.json")
        try FileManager.default.copyItem(at: source, to: url)
        return url
    }

    func testOpeningAFileAsksPlayOrEditBeforeDoingAnything() throws {
        coordinator.open(url: try boardFile())
        XCTAssertNotNil(coordinator.pendingBoard)
        XCTAssertTrue(started.isEmpty)
        XCTAssertEqual(editorShown, 0)
    }

    func testPlayWithNoGameStartsItAndRemembersTheFile() async throws {
        let url = try boardFile()
        coordinator.open(url: url)
        await coordinator.play(try XCTUnwrap(coordinator.pendingBoard))
        XCTAssertEqual(started.count, 1)
        XCTAssertNil(coordinator.pendingBoard)
        XCTAssertEqual(recents.urls.map(\.lastPathComponent), ["game.macpardy"])
    }

    func testPlayDuringAGameWaitsForConfirmation() async throws {
        coordinator.isGameRunning = { true }
        coordinator.open(url: try boardFile())
        await coordinator.play(try XCTUnwrap(coordinator.pendingBoard))
        XCTAssertTrue(started.isEmpty)
        let pending = try XCTUnwrap(coordinator.pendingReplacement)
        coordinator.confirmReplacement(pending)
        XCTAssertEqual(started.count, 1)
        XCTAssertNil(coordinator.pendingReplacement)
    }

    func testEditQueuesTheDraftAndNeverStartsAGame() throws {
        coordinator.isGameRunning = { true }
        coordinator.open(url: try editableFile())
        coordinator.edit(try XCTUnwrap(coordinator.pendingBoard))
        XCTAssertTrue(started.isEmpty)
        XCTAssertNil(coordinator.pendingReplacement)
        XCTAssertNotNil(session.pendingDraft)
        XCTAssertEqual(editorShown, 1)
        XCTAssertEqual(recents.urls.map(\.lastPathComponent), ["edit.json"])
    }

    func testEditWithUnsavedEditorChangesAsksFirst() throws {
        let url = try editableFile()
        session.hasUnsavedEdits = true
        coordinator.open(url: url)
        coordinator.edit(try XCTUnwrap(coordinator.pendingBoard))
        let pending = try XCTUnwrap(coordinator.pendingEdit)
        XCTAssertEqual(editorShown, 0)
        coordinator.confirmEdit(pending)
        XCTAssertEqual(editorShown, 1)
        XCTAssertNotNil(session.pendingDraft)
    }

    func testMissingFileShowsAnErrorAndLeavesTheRecentList() async throws {
        let url = directory.appendingPathComponent("gone.macpardy")
        recents.note(url)
        coordinator.open(url: url)
        await coordinator.play(try XCTUnwrap(coordinator.pendingBoard))
        XCTAssertNotNil(coordinator.loadError)
        XCTAssertTrue(recents.urls.isEmpty)
        XCTAssertTrue(started.isEmpty)
    }
}
