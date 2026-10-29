//
//  BoardLoaderTests.swift
//  MacopardyTests
//

import XCTest
@testable import Macopardy

@MainActor
final class BoardLoaderTests: XCTestCase {

    private typealias LoadError = BoardLoader.LoadError

    // MARK: - Helpers

    /// A full editor game. Daily Doubles on round 1 (0, 2) and round 2 (3, 4).
    private func makeDraft(title: String = "Trivia Night", image: Data? = nil) -> BoardDraft {
        func categories(_ round: Int, values: [Int]) -> [DraftCategory] {
            (1...6).map { c in
                DraftCategory(
                    title: "R\(round) Cat \(c)",
                    questions: values.enumerated().map { row, value in
                        DraftQuestion(
                            value: value,
                            clue: "Clue \(round)-\(c)-\(value)",
                            response: "Answer \(round)-\(c)-\(value)",
                            isDailyDouble: (round == 1 && c == 1 && row == 2) || (round == 2 && c == 4 && row == 4)
                        )
                    }
                )
            }
        }

        var draft = BoardDraft(
            title: title,
            round1Title: "Warm Up",
            round1Categories: categories(1, values: BoardDefaults.round1Values),
            round1Values: BoardDefaults.round1Values,
            round2Title: "Turning Up the Heat",
            round2Categories: categories(2, values: BoardDefaults.round2Values),
            round2Values: BoardDefaults.round2Values,
            finalTitle: "The Last Word",
            finalMacpardy: DraftFinalMacpardy(category: "Final Cat", clue: "Final clue", response: "Final answer")
        )
        if let image {
            draft.round1Categories[1].questions[3].image = QuestionImage(path: "images/source.png", data: image)
        }
        return draft
    }

    /// Board content without IDs, so boards built at different times compare.
    private func content(_ boards: [MacpardyBoard]) -> [String] {
        boards.flatMap { board in
            ["board \(board.title) \(board.round)"] + board.categories.flatMap { category in
                ["  category \(category.title)"] + category.questions.map { q in
                    "    \(q.value) | \(q.clue) | \(q.response) | dd=\(q.isDailyDouble) | image=\(q.image?.data?.count ?? -1)"
                }
            }
        }
    }

    private func loadError(_ data: Data, fileName: String) -> LoadError? {
        do {
            _ = try BoardLoader.load(data: data, fileName: fileName)
            XCTFail("Expected \(fileName) to fail")
            return nil
        } catch let error as LoadError {
            return error
        } catch {
            XCTFail("Unexpected error \(error)")
            return nil
        }
    }

    private func json(_ boards: [MacpardyBoard], title: String? = "Trivia Night") throws -> Data {
        try MacpardyJSONBoardDocument.encode(boards, title: title)
    }

    // MARK: - Dispatch by extension

    func testFileKindFromExtension() {
        XCTAssertEqual(BoardLoader.FileKind(fileExtension: "json"), .json)
        XCTAssertEqual(BoardLoader.FileKind(fileExtension: "JSON"), .json)
        XCTAssertEqual(BoardLoader.FileKind(fileExtension: "macpardy"), .package)
        XCTAssertEqual(BoardLoader.FileKind(fileExtension: "zip"), .package)
        XCTAssertEqual(BoardLoader.FileKind(fileExtension: "csv"), .csv)
        XCTAssertNil(BoardLoader.FileKind(fileExtension: "txt"))
        XCTAssertNil(BoardLoader.FileKind(fileExtension: ""))
    }

    func testUnsupportedExtensionIsRejected() {
        XCTAssertEqual(loadError(Data("hello".utf8), fileName: "notes.txt"), .unsupportedFileType("txt"))
    }

    func testJSONExtensionDoesNotAcceptAPackage() throws {
        let package = try BoardPackage.write(makeDraft().makeBoards(), title: "Trivia Night")
        XCTAssertEqual(
            loadError(package, fileName: "game.json"),
            .json(BoardLoader.JSONProblem(kind: .notJSON, path: nil, inPackage: false))
        )
    }

    // MARK: - JSON

    func testJSONRoundTripsThroughTheEditor() throws {
        let boards = makeDraft().makeBoards()
        let draft = try BoardLoader.load(data: try json(boards), fileName: "anything.json")

        XCTAssertEqual(draft.title, "Trivia Night")
        XCTAssertFalse(draft.hasImages)
        XCTAssertEqual(content(draft.makeBoards()), content(boards))
    }

    func testLegacyJSONLoads() throws {
        let boards = makeDraft().makeBoards()
        let legacy = try JSONEncoder().encode(boards)
        let draft = try BoardLoader.load(data: legacy, fileName: "old.json")
        XCTAssertEqual(content(draft.makeBoards()), content(boards))
        XCTAssertEqual(draft.title, "old", "Legacy files have no game title, so the file name is used")
    }

    // MARK: - Titles

    func testGameAndRoundTitlesRoundTrip() throws {
        let boards = makeDraft().makeBoards()
        XCTAssertEqual(boards.map(\.title), ["Warm Up", "Turning Up the Heat", "The Last Word"])

        let draft = try BoardLoader.load(data: try json(boards, title: "Trivia Night"), fileName: "renamed-file.json")
        XCTAssertEqual(draft.title, "Trivia Night", "The saved game title wins over the file name")
        XCTAssertEqual(draft.round1Title, "Warm Up")
        XCTAssertEqual(draft.round2Title, "Turning Up the Heat")
        XCTAssertEqual(draft.finalTitle, "The Last Word")
    }

    func testPackageKeepsGameTitle() throws {
        let package = try BoardPackage.write(makeDraft().makeBoards(), title: "Packaged Night")
        XCTAssertEqual(try BoardPackage.readGame(package).title, "Packaged Night")
        XCTAssertEqual(try BoardLoader.load(data: package, fileName: "x.macpardy").title, "Packaged Night")
    }

    func testFileWithoutGameTitleStillLoads() throws {
        let data = try json(makeDraft().makeBoards(), title: nil)
        XCTAssertFalse(String(decoding: data, as: UTF8.self).contains("\"title\" : \"Trivia"), "No game title is written when there isn't one")
        XCTAssertNil(try BoardPackage.decodeGameJSON(data).title)
        XCTAssertEqual(try BoardLoader.load(data: data, fileName: "from-file.json").title, "from-file")
    }

    func testOldSuffixedBoardTitleGivesGameTitle() throws {
        var boards = makeDraft().makeBoards()
        boards[0].title = "Old Game - Macpardy"
        let draft = try BoardLoader.load(data: try json(boards, title: nil), fileName: "file.json")
        XCTAssertEqual(draft.title, "Old Game")
        XCTAssertEqual(draft.round1Title, "Old Game - Macpardy", "Round titles load as saved")
    }

    func testBlankRoundTitlesGetTheRoundName() {
        var draft = makeDraft()
        draft.round1Title = "  "
        draft.round2Title = ""
        draft.finalTitle = ""
        XCTAssertEqual(
            draft.makeBoards().map(\.title),
            [MacpardyRound.macpardy, .doubleMacpardy, .finalMacpardy].map(\.displayName)
        )
    }

    func testPreFilledDraftMatchesFile() throws {
        let boards = makeDraft().makeBoards()
        let draft = try BoardLoader.load(data: try json(boards), fileName: "game.json")

        XCTAssertEqual(draft.round1Values, BoardDefaults.round1Values)
        XCTAssertEqual(draft.round2Values, BoardDefaults.round2Values)
        XCTAssertEqual(draft.round1Categories.map(\.title), boards[0].categories.map(\.title))
        XCTAssertEqual(draft.round2Categories.map(\.title), boards[1].categories.map(\.title))
        XCTAssertTrue(draft.round1Categories[0].questions[2].isDailyDouble)
        XCTAssertTrue(draft.round2Categories[3].questions[4].isDailyDouble)
        XCTAssertEqual(draft.round1Categories[5].questions[4].clue, "Clue 1-6-1000")
        XCTAssertEqual(draft.finalMacpardy.category, "Final Cat")
        XCTAssertEqual(draft.finalMacpardy.clue, "Final clue")
        XCTAssertEqual(draft.finalMacpardy.response, "Final answer")
    }

    func testNonStandardValuesAndOrderAreKept() throws {
        var boards = makeDraft().makeBoards()
        boards[0].categories = boards[0].categories.map { category in
            // Values 100–500, stored out of order.
            Category(title: category.title, questions: [300, 100, 500, 200, 400].map {
                Question(value: $0, clue: "c\($0)", response: "r\($0)")
            })
        }
        let draft = try BoardLoader.load(data: try json(boards), fileName: "game.json")
        XCTAssertEqual(draft.round1Values, [100, 200, 300, 400, 500])
        XCTAssertEqual(draft.round1Categories[0].questions.map(\.clue), ["c100", "c200", "c300", "c400", "c500"])
    }

    func testInvalidJSONNamesTheProblem() {
        XCTAssertEqual(
            loadError(Data("{ not json".utf8), fileName: "game.json"),
            .json(BoardLoader.JSONProblem(kind: .notJSON, path: nil, inPackage: false))
        )
    }

    func testMissingFieldNamesTheField() throws {
        var object = try JSONSerialization.jsonObject(with: try json(makeDraft().makeBoards())) as! [String: Any]
        var boards = object["boards"] as! [[String: Any]]
        var categories = boards[1]["categories"] as! [[String: Any]]
        categories[2].removeValue(forKey: "title")
        boards[1]["categories"] = categories
        object["boards"] = boards
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertEqual(
            loadError(data, fileName: "game.json"),
            .json(BoardLoader.JSONProblem(kind: .missingField, path: "boards[1].categories[2].title", inPackage: false))
        )
    }

    func testBrokenLegacyJSONNamesTheField() throws {
        var array = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(makeDraft().makeBoards())) as! [[String: Any]]
        array[0]["round"] = "triple"
        let data = try JSONSerialization.data(withJSONObject: array)

        XCTAssertEqual(
            loadError(data, fileName: "old.json"),
            .json(BoardLoader.JSONProblem(kind: .invalidValue, path: "[0].round", inPackage: false))
        )
    }

    // MARK: - Packages

    func testPackageWithImagesRoundTrips() throws {
        let png = TestImages.make(width: 40, height: 30)
        let boards = makeDraft(image: png).makeBoards()
        let package = try BoardPackage.write(boards, title: "Trivia Night")

        let draft = try BoardLoader.load(data: package, fileName: "game.macpardy")
        XCTAssertTrue(draft.hasImages)
        XCTAssertEqual(draft.round1Categories[1].questions[3].image?.data, png)

        let reloaded = try BoardPackage.read(try BoardPackage.write(draft.makeBoards()))
        XCTAssertEqual(content(reloaded), content(boards))
        XCTAssertEqual(reloaded[0].categories[1].questions[3].image?.data, png)
    }

    func testZipExtensionLoadsAPackage() throws {
        let package = try BoardPackage.write(makeDraft().makeBoards())
        XCTAssertNoThrow(try BoardLoader.load(data: package, fileName: "game.zip"))
    }

    func testMissingImageKeepsPlaceholderReference() throws {
        var boards = makeDraft().makeBoards()
        boards[0].categories[0].questions[0].image = QuestionImage(path: "images/gone.png", data: nil)
        let encoder = JSONEncoder()
        encoder.userInfo[.omitQuestionImageData] = true
        let boardJSON = try encoder.encode(BoardPackage.BoardFile(formatVersion: BoardPackage.formatVersion, boards: boards))
        let package = try BoardPackage.makeArchive(entries: [(path: BoardPackage.boardFileName, data: boardJSON)])

        let draft = try BoardLoader.load(data: package, fileName: "game.macpardy")
        let image = draft.round1Categories[0].questions[0].image
        XCTAssertEqual(image?.path, "images/gone.png")
        XCTAssertNil(image?.data)
        XCTAssertFalse(draft.hasImages)
    }

    func testCorruptPackageIsRejected() {
        XCTAssertEqual(
            loadError(Data([0x50, 0x4B, 0x03, 0x04, 0x01, 0x02, 0x03]), fileName: "game.macpardy"),
            .package(.archiveUnreadable)
        )
        XCTAssertEqual(loadError(Data("plain text".utf8), fileName: "game.zip"), .package(.archiveUnreadable))
    }

    func testPackageWithoutBoardFileIsRejected() throws {
        let package = try BoardPackage.makeArchive(entries: [(path: "images/a.png", data: TestImages.make(width: 2, height: 2))])
        XCTAssertEqual(loadError(package, fileName: "game.macpardy"), .package(.missingBoardFile))
    }

    func testBrokenBoardJSONInPackageNamesTheField() throws {
        let package = try BoardPackage.makeArchive(entries: [(path: BoardPackage.boardFileName, data: Data(#"{"formatVersion":2}"#.utf8))])
        XCTAssertEqual(
            loadError(package, fileName: "game.macpardy"),
            .json(BoardLoader.JSONProblem(kind: .missingField, path: "boards", inPackage: true))
        )
    }

    // MARK: - CSV

    func testCSVLoadsWithFileNameAsTitle() throws {
        let draft = try BoardLoader.load(data: CSVBoardTemplate.makeData(), fileName: "Pub Quiz.csv")
        let expected = try CSVBoardImporter.importBoards(from: CSVBoardTemplate.makeData(), title: "Pub Quiz")

        XCTAssertEqual(draft.title, "Pub Quiz")
        XCTAssertFalse(draft.hasImages, "CSV boards have no pictures, so they export as JSON")
        XCTAssertEqual(content(draft.makeBoards()), content(expected))
    }

    func testCSVExportReloadsAsJSON() throws {
        let draft = try BoardLoader.load(data: CSVBoardTemplate.makeData(), fileName: "quiz.csv")
        let exported = try json(draft.makeBoards())
        let reloaded = try BoardLoader.load(data: exported, fileName: "quiz.json")
        XCTAssertEqual(content(reloaded.makeBoards()), content(draft.makeBoards()))
    }

    func testBadCSVRowReportsRowAndColumn() throws {
        var rows = CSVBoardTemplate.makeRows()
        let questionColumn = rows[0].firstIndex(of: CSVBoardImporter.Column.question.rawValue)!
        rows[2][questionColumn] = ""  // spreadsheet row 3

        guard case .csv(let issues)? = loadError(Data(CSVParser.write(rows).utf8), fileName: "quiz.csv") else {
            return XCTFail("Expected CSV issues")
        }
        XCTAssertEqual(issues, [CSVBoardImporter.Issue(row: 3, column: .question, kind: .emptyCell)])
    }

    // MARK: - Shape

    func testMissingRoundIsRejected() throws {
        let boards = Array(makeDraft().makeBoards().prefix(2))
        XCTAssertEqual(loadError(try json(boards), fileName: "game.json"), .shape(.missingRound(.finalMacpardy)))
    }

    func testDuplicateRoundIsRejected() throws {
        var boards = makeDraft().makeBoards()
        boards.append(boards[0])
        XCTAssertEqual(loadError(try json(boards), fileName: "game.json"), .shape(.duplicateRound(.macpardy)))
    }

    func testTooFewCategoriesAreRejected() throws {
        var boards = makeDraft().makeBoards()
        boards[0].categories.removeLast()
        XCTAssertEqual(
            loadError(try json(boards), fileName: "game.json"),
            .shape(.wrongCategoryCount(round: .macpardy, found: 5))
        )
    }

    func testTooManyCategoriesAreRejected() throws {
        var boards = makeDraft().makeBoards()
        boards[1].categories.append(boards[1].categories[0])
        XCTAssertEqual(
            loadError(try json(boards), fileName: "game.json"),
            .shape(.wrongCategoryCount(round: .doubleMacpardy, found: 7))
        )
    }

    func testWrongClueCountIsRejected() throws {
        var boards = makeDraft().makeBoards()
        boards[1].categories[2].questions.removeLast()
        XCTAssertEqual(
            loadError(try json(boards), fileName: "game.json"),
            .shape(.wrongClueCount(round: .doubleMacpardy, category: "R2 Cat 3", found: 4))
        )

        boards = makeDraft().makeBoards()
        boards[0].categories[0].questions.append(Question(value: 1200, clue: "Extra", response: "Extra"))
        XCTAssertEqual(
            loadError(try json(boards), fileName: "game.json"),
            .shape(.wrongClueCount(round: .macpardy, category: "R1 Cat 1", found: 6))
        )
    }

    func testMismatchedValuesAreRejected() throws {
        var boards = makeDraft().makeBoards()
        var questions = boards[1].categories[2].questions
        questions[4] = Question(value: 2500, clue: "c", response: "r")
        boards[1].categories[2].questions = questions
        XCTAssertEqual(
            loadError(try json(boards), fileName: "game.json"),
            .shape(.mismatchedValues(
                round: .doubleMacpardy,
                category: "R2 Cat 3",
                expected: BoardDefaults.round2Values,
                found: Array(BoardDefaults.round2Values.dropLast()) + [2500]
            ))
        )
    }

    func testFinalWithTwoCluesIsRejected() throws {
        var boards = makeDraft().makeBoards()
        boards[2].categories[0].questions.append(Question(value: 0, clue: "Extra", response: "Extra"))
        XCTAssertEqual(loadError(try json(boards), fileName: "game.json"), .shape(.finalShape(categories: 1, questions: 2)))
    }

    // MARK: - Titles

    func testCountErrorsSayWhy() {
        let categories = LoadError.shape(.wrongCategoryCount(round: .macpardy, found: 5)).problems[0]
        XCTAssertTrue(categories.message.contains("5"))
        XCTAssertTrue(categories.location?.contains(MacpardyRound.macpardy.displayName) == true)

        let clues = LoadError.shape(.wrongClueCount(round: .doubleMacpardy, category: "Science", found: 4)).problems[0]
        XCTAssertTrue(clues.message.contains("4"))
        XCTAssertTrue(clues.location?.contains("Science") == true)
    }

    func testTitleFallsBackToFileName() {
        XCTAssertEqual(BoardDraft.gameTitle(fromBoardTitle: "Trivia - Macpardy", fallback: "file"), "Trivia")
        XCTAssertEqual(BoardDraft.gameTitle(fromBoardTitle: "Round 1", fallback: "my-board"), "my-board")
        XCTAssertEqual(BoardDraft.gameTitle(fromBoardTitle: "Round 1", fallback: " "), "Round 1")
        XCTAssertEqual(BoardDraft.gameTitle(fromBoardTitle: " - Macpardy", fallback: "file"), "file")
    }

    // MARK: - Messages

    func testEveryErrorHasAMessage() {
        let errors: [LoadError] = [
            .unsupportedFileType("txt"),
            .unreadable("No permission"),
            .csv([CSVBoardImporter.Issue(row: 3, column: .question, kind: .emptyCell)]),
            .json(BoardLoader.JSONProblem(kind: .missingField, path: "boards[0].title", inPackage: false)),
            .json(BoardLoader.JSONProblem(kind: .notJSON, path: nil, inPackage: true)),
            .package(.missingBoardFile),
            .package(.unsupportedFormatVersion(9)),
            .shape(.missingRound(.finalMacpardy)),
            .shape(.wrongCategoryCount(round: .macpardy, found: 5)),
            .shape(.wrongClueCount(round: .doubleMacpardy, category: "Science", found: 4)),
            .shape(.mismatchedValues(round: .macpardy, category: "Science", expected: [1, 2], found: [1])),
            .shape(.finalShape(categories: 2, questions: 2)),
        ]
        for error in errors {
            XCTAssertFalse(error.problems.isEmpty, "\(error)")
            XCTAssertTrue(error.problems.allSatisfy { !$0.message.isEmpty }, "\(error)")
        }
    }

    func testJSONLocationIncludesFieldPath() {
        let problem = BoardLoader.JSONProblem(kind: .wrongType, path: "boards[0].categories[1].questions[2].value", inPackage: false)
        XCTAssertTrue(problem.displayProblem.location?.contains("boards[0].categories[1].questions[2].value") == true)
    }

    // MARK: - Editor session

    func testSessionHandsOverDraftOnce() {
        let session = BoardEditorSession()
        XCTAssertNil(session.takePendingDraft())

        session.edit(makeDraft(title: "Queued"))
        XCTAssertEqual(session.editRequest, 1)
        XCTAssertEqual(session.takePendingDraft()?.title, "Queued")
        XCTAssertNil(session.takePendingDraft())
    }

    func testOnlyOneCloseRequestAtATime() {
        let session = BoardEditorSession()
        XCTAssertTrue(session.requestClose(.closeWindow))
        XCTAssertFalse(session.requestClose(.quitApp))
        XCTAssertEqual(session.closeRequest, .closeWindow)

        session.finishClose(proceed: false)
        XCTAssertNil(session.closeRequest)
        XCTAssertTrue(session.requestClose(.quitApp))
    }

    func testQuitDecisionIsReported() {
        let session = BoardEditorSession()
        var decisions: [Bool] = []
        session.onQuitDecision = { decisions.append($0) }

        session.requestClose(.quitApp)
        session.finishClose(proceed: false)
        XCTAssertEqual(decisions, [false])

        session.onQuitDecision = { decisions.append($0) }
        session.requestClose(.quitApp)
        session.finishClose(proceed: true)
        XCTAssertEqual(decisions, [false, true])
        XCTAssertNil(session.onQuitDecision)
    }

    func testClosingAWindowDoesNotAnswerAQuit() {
        let session = BoardEditorSession()
        var decisions: [Bool] = []
        session.onQuitDecision = { decisions.append($0) }
        session.requestClose(.closeWindow)
        session.finishClose(proceed: true)
        XCTAssertTrue(decisions.isEmpty)
    }
}
