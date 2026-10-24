//
//  QuestionImageAutoSaveTests.swift
//  MacopardyTests
//

import XCTest
@testable import Macopardy

@MainActor
final class QuestionImageAutoSaveTests: XCTestCase {

    private var tempDirectory: URL!

    override func setUpWithError() throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("QuestionImageAutoSaveTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDirectory)
    }

    func testSnapshotEncodingEmbedsImageData() throws {
        let png = TestImages.make(width: 20, height: 20)
        var board = MacpardyBoard.sample
        board.categories[0].questions[0].image = QuestionImage(path: "images/q.png", data: png)
        let snapshot = GameSnapshot(game: Game(rounds: [board], teams: Team.sampleTeams), phase: .board)

        let decoded = try JSONDecoder().decode(GameSnapshot.self, from: try JSONEncoder().encode(snapshot))
        XCTAssertEqual(decoded.game.rounds[0].categories[0].questions[0].image?.data, png)
    }

    func testResumeWithImageAfterBoardFileIsDeleted() async throws {
        let png = TestImages.make(width: 64, height: 48)
        var board = MacpardyBoard.sample
        board.categories[1].questions[2].image = QuestionImage(path: "images/draft.png", data: png)

        // Save the board as a package, then open it like the app does.
        let boardURL = tempDirectory.appendingPathComponent("game.macpardy")
        try BoardPackage.write([board]).write(to: boardURL)
        let boards = try await FileManagerService().readBoards(from: boardURL)

        let state = GameState(rounds: boards, teams: Team.sampleTeams)
        let category = boards[0].categories[1]
        let question = category.questions[2]
        let snapshot = GameSnapshot(
            game: state.game,
            phase: .question,
            currentQuestionID: question.id,
            currentCategoryTitle: category.title
        )

        let store = GameSaveStore(baseDirectory: tempDirectory.appendingPathComponent("save", isDirectory: true))
        try await store.save(snapshot)

        // The original board file goes away; resume must not need it.
        try FileManager.default.removeItem(at: boardURL)

        let saved = await store.load()
        let loaded = try XCTUnwrap(saved)
        let resumed = GameState()
        resumed.restore(from: loaded)

        XCTAssertEqual(resumed.phase, .question)
        XCTAssertEqual(resumed.currentQuestion?.id, question.id)
        XCTAssertEqual(resumed.currentQuestion?.image?.data, png)
        XCTAssertNotNil(resumed.currentQuestion?.image?.nsImage)
        XCTAssertEqual(resumed.game.rounds[0].categories[1].questions[2].image?.data, png)
    }

    func testResumeWithoutImages() async throws {
        let store = GameSaveStore(baseDirectory: tempDirectory)
        let snapshot = GameSnapshot(game: Game(rounds: [MacpardyBoard.sample], teams: Team.sampleTeams), phase: .board)
        try await store.save(snapshot)

        let saved = await store.load()
        let loaded = try XCTUnwrap(saved)
        XCTAssertEqual(loaded.game, snapshot.game)
    }
}
