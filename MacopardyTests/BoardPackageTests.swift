//
//  BoardPackageTests.swift
//  MacopardyTests
//

import XCTest
@testable import Macopardy

@MainActor
final class BoardPackageTests: XCTestCase {

    private func boardsWithImage(_ data: Data) -> (boards: [MacpardyBoard], questionID: UUID) {
        var board = MacpardyBoard.sample
        board.categories[0].questions[0].image = QuestionImage(path: "images/draft.png", data: data)
        return ([board], board.categories[0].questions[0].id)
    }

    private func boardJSON(_ boards: [MacpardyBoard], version: Int = BoardPackage.formatVersion) throws -> Data {
        let encoder = JSONEncoder()
        encoder.userInfo[.omitQuestionImageData] = true
        return try encoder.encode(BoardPackage.BoardFile(formatVersion: version, boards: boards))
    }

    // MARK: - Round trips

    func testRoundTripWithImages() throws {
        let png = TestImages.make(width: 40, height: 30)
        let (boards, questionID) = boardsWithImage(png)

        let packaged = try BoardPackage.write(boards)
        XCTAssertTrue(BoardPackage.isZip(packaged))

        let loaded = try BoardPackage.read(packaged)
        let question = loaded[0].categories[0].questions[0]
        XCTAssertEqual(question.id, questionID)
        XCTAssertEqual(question.image?.data, png)
        XCTAssertEqual(question.image?.path, "images/\(questionID.uuidString.lowercased()).png")
        XCTAssertNil(loaded[0].categories[0].questions[1].image)
        XCTAssertEqual(loaded[0].categories.map(\.title), boards[0].categories.map(\.title))
    }

    func testRoundTripWithoutImages() throws {
        let boards = [MacpardyBoard.sample]
        let loaded = try BoardPackage.read(try BoardPackage.write(boards))
        XCTAssertEqual(loaded, boards)
    }

    func testImageWithoutDataIsDroppedOnWrite() throws {
        var board = MacpardyBoard.sample
        board.categories[0].questions[0].image = QuestionImage(path: "images/gone.png", data: nil)
        let loaded = try BoardPackage.read(try BoardPackage.write([board]))
        XCTAssertNil(loaded[0].categories[0].questions[0].image)
    }

    // MARK: - Legacy and plain JSON

    func testLegacyJSONLoads() throws {
        let legacy = """
        [{"id":"6F9619FF-8B86-D011-B42D-00CF4FC964FF","title":"Old Board","round":"macpardy","categories":[
          {"id":"7F9619FF-8B86-D011-B42D-00CF4FC964FF","title":"Science","questions":[
            {"id":"8F9619FF-8B86-D011-B42D-00CF4FC964FF","value":200,"clue":"Clue","response":"Response","hasBeenPlayed":false,"isDailyDouble":true}
          ]}
        ]}]
        """
        let boards = try MacpardyBoardsDocument.decodeBoards(from: Data(legacy.utf8))
        XCTAssertEqual(boards.count, 1)
        XCTAssertEqual(boards[0].title, "Old Board")
        let question = boards[0].categories[0].questions[0]
        XCTAssertEqual(question.clue, "Clue")
        XCTAssertTrue(question.isDailyDouble)
        XCTAssertNil(question.image)
    }

    func testVersionedBoardJSONLoadsDirectly() throws {
        let boards = [MacpardyBoard.sample]
        XCTAssertEqual(try BoardPackage.read(try boardJSON(boards)), boards)
    }

    func testNewerFormatVersionIsRejected() throws {
        let data = try boardJSON([MacpardyBoard.sample], version: BoardPackage.formatVersion + 1)
        XCTAssertThrowsError(try BoardPackage.read(data)) { error in
            XCTAssertEqual(error as? BoardPackage.PackageError, .unsupportedFormatVersion(BoardPackage.formatVersion + 1))
        }
    }

    func testPackageWithOnlyBoardJSONLoads() throws {
        let boards = [MacpardyBoard.sample]
        let packaged = try BoardPackage.makeArchive(entries: [(path: "board.json", data: try boardJSON(boards))])
        XCTAssertEqual(try BoardPackage.read(packaged), boards)
    }

    func testPackageWithoutBoardJSONIsRejected() throws {
        let packaged = try BoardPackage.makeArchive(entries: [(path: "images/a.png", data: TestImages.make(width: 2, height: 2))])
        XCTAssertThrowsError(try BoardPackage.read(packaged)) { error in
            XCTAssertEqual(error as? BoardPackage.PackageError, .missingBoardFile)
        }
    }

    // MARK: - Bad images

    func testMissingImageFileStillLoadsBoard() throws {
        var board = MacpardyBoard.sample
        board.categories[0].questions[0].image = QuestionImage(path: "images/missing.png", data: nil)
        let packaged = try BoardPackage.makeArchive(entries: [(path: "board.json", data: try boardJSON([board]))])

        let loaded = try BoardPackage.read(packaged)
        let image = try XCTUnwrap(loaded[0].categories[0].questions[0].image)
        XCTAssertEqual(image.path, "images/missing.png")
        XCTAssertNil(image.data)
        XCTAssertNil(image.nsImage)
    }

    func testCorruptImageDataStillLoadsBoard() throws {
        var board = MacpardyBoard.sample
        board.categories[0].questions[0].image = QuestionImage(path: "images/bad.png", data: nil)
        let packaged = try BoardPackage.makeArchive(entries: [
            (path: "board.json", data: try boardJSON([board])),
            (path: "images/bad.png", data: Data("definitely not a png".utf8)),
        ])

        let loaded = try BoardPackage.read(packaged)
        let image = try XCTUnwrap(loaded[0].categories[0].questions[0].image)
        XCTAssertNotNil(image.data)
        XCTAssertNil(image.nsImage, "Corrupt data should fall back to the placeholder")
    }

    func testUnsafeImagePathIsIgnored() throws {
        var board = MacpardyBoard.sample
        board.categories[0].questions[0].image = QuestionImage(path: "../board.json", data: nil)
        let packaged = try BoardPackage.makeArchive(entries: [(path: "board.json", data: try boardJSON([board]))])

        let loaded = try BoardPackage.read(packaged)
        XCTAssertNil(loaded[0].categories[0].questions[0].image?.data)
    }

    func testSafeImagePathRules() {
        XCTAssertTrue(BoardPackage.isSafeImagePath("images/a.png"))
        XCTAssertFalse(BoardPackage.isSafeImagePath("images/../a.png"))
        XCTAssertFalse(BoardPackage.isSafeImagePath("../a.png"))
        XCTAssertFalse(BoardPackage.isSafeImagePath("/images/a.png"))
        XCTAssertFalse(BoardPackage.isSafeImagePath("images/"))
        XCTAssertFalse(BoardPackage.isSafeImagePath("images/.."))
        XCTAssertFalse(BoardPackage.isSafeImagePath("board.json"))
    }

    func testDefaultFilenameUsesPackageExtension() {
        XCTAssertEqual(FileManagerService().defaultFilename(for: "My Game"), "My-Game.macpardy")
    }
}
