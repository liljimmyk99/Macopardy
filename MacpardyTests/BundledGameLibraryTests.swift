//
//  BundledGameLibraryTests.swift
//  MacpardyTests
//

import XCTest
@testable import Macpardy

@MainActor
final class BundledGameLibraryTests: XCTestCase {

    private var games: [BundledGame] {
        BundledGameLibrary.games()
    }

    func testGamesShipInTheAppBundle() {
        XCTAssertNotNil(BundledGameLibrary.bundledDirectory)
        XCTAssertTrue((2...3).contains(games.count), "expected 2-3 built-in games, found \(games.count)")
    }

    func testEveryBundledGameLoadsWithItsTitle() throws {
        let directory = try XCTUnwrap(BundledGameLibrary.bundledDirectory)
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }

        // A file that fails to load is dropped from the list, so compare counts.
        XCTAssertEqual(games.count, files.count, "a bundled game failed to load")
        for game in games {
            XCTAssertFalse(game.title.isEmpty, game.id)
        }
        XCTAssertEqual(Set(games.map(\.title)).count, games.count, "built-in titles must be unique")
    }

    func testEveryBundledGameIsValidAndPlayable() throws {
        for game in games {
            // `BoardLoader` enforces the 6x5 shape of both rounds and the single final clue.
            let draft = try BundledGameLibrary.draft(for: game)
            XCTAssertFalse(draft.hasImages, "\(game.id): built-in games are text only")

            let boards = try BundledGameLibrary.boards(for: game)
            XCTAssertEqual(boards.map(\.round), [.macpardy, .doubleMacpardy, .finalMacpardy], game.id)

            let dailyDoubles = boards.map { board in
                board.categories.flatMap(\.questions).filter(\.isDailyDouble).count
            }
            XCTAssertEqual(dailyDoubles[0], 1, "\(game.id): round 1 Daily Doubles")
            XCTAssertEqual(dailyDoubles[1], 2, "\(game.id): round 2 Daily Doubles")
            XCTAssertEqual(dailyDoubles[2], 0, "\(game.id): final Daily Doubles")

            for board in boards {
                XCTAssertFalse(board.title.trimmingCharacters(in: .whitespaces).isEmpty, game.id)
                for question in board.categories.flatMap(\.questions) {
                    XCTAssertFalse(question.clue.isEmpty, game.id)
                    XCTAssertFalse(question.response.isEmpty, game.id)
                }
            }

            let final = try XCTUnwrap(boards.last?.categories.first, game.id)
            XCTAssertEqual(final.questions.count, 1, game.id)
        }
    }

    func testMissingDirectoryListsNothing() {
        let missing = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        XCTAssertTrue(BundledGameLibrary.games(in: missing).isEmpty)
        XCTAssertTrue(BundledGameLibrary.games(in: nil).isEmpty)
    }

    func testBrokenFileIsSkippedNotListed() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        try Data("not json".utf8).write(to: directory.appendingPathComponent("broken.json"))
        let good = try XCTUnwrap(games.first)
        let source = try XCTUnwrap(BundledGameLibrary.bundledDirectory).appendingPathComponent(good.id)
        try FileManager.default.copyItem(at: source, to: directory.appendingPathComponent(good.id))

        XCTAssertEqual(BundledGameLibrary.games(in: directory), [good])
    }

    func testCopyFilenameKeepsTheTitleAndAddsCopy() {
        XCTAssertEqual(BundledGameLibrary.copyFilename(for: "Classic Game 1"), "Classic Game 1 copy.json")
        XCTAssertEqual(BundledGameLibrary.copyFilename(for: "A/B: C"), "A-B- C copy.json")
        XCTAssertEqual(BundledGameLibrary.copyFilename(for: "  "), "macpardy-game copy.json")
    }

    func testEditSessionPassesTheSuggestedFilenameOnce() throws {
        let session = BoardEditorSession()
        let draft = try BundledGameLibrary.draft(for: try XCTUnwrap(games.first))

        session.edit(draft, suggestedFilename: "X copy.json")
        XCTAssertEqual(session.takePendingDraft(), draft)
        XCTAssertEqual(session.takePendingSuggestedFilename(), "X copy.json")
        XCTAssertNil(session.takePendingSuggestedFilename())

        session.edit(draft)
        XCTAssertNil(session.takePendingSuggestedFilename())
    }

    /// A save holds the whole board, so a resumed built-in game doesn't
    /// depend on the bundled file still being there or unchanged.
    func testSavedBuiltInGameResumesWithoutTheBundledFile() throws {
        let game = try XCTUnwrap(games.first)
        let boards = try BundledGameLibrary.boards(for: game)
        let state = GameState()
        state.loadGame(boards: boards)

        let snapshot = try JSONDecoder().decode(
            GameSnapshot.self,
            from: JSONEncoder().encode(GameSnapshot(from: state))
        )

        // Resume against an empty library: the save alone must be enough.
        let empty = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        XCTAssertTrue(BundledGameLibrary.games(in: empty).isEmpty)

        let resumed = GameState()
        resumed.restore(from: snapshot)
        XCTAssertEqual(resumed.game.rounds, boards)
    }
}
