//
//  CSVBoardImporterTests.swift
//  MacpardyTests
//

import XCTest
@testable import Macpardy

@MainActor
final class CSVBoardImporterTests: XCTestCase {

    private typealias Issue = CSVBoardImporter.Issue

    private let header = ["round", "category", "value", "question", "answer", "daily_double"]

    /// A complete, valid game: 6×5 single, 6×5 double, one final (62 rows).
    /// `rows[i]` is spreadsheet row `i + 1`: the header is row 1, single
    /// round is rows 2–31, double round 32–61, final row 62.
    private func validRows() -> [[String]] {
        var rows = [header]
        for (round, values) in [("single", [200, 400, 600, 800, 1000]), ("double", [400, 800, 1200, 1600, 2000])] {
            for c in 1...6 {
                for value in values {
                    rows.append([round, "\(round) cat \(c)", String(value), "Clue \(round) \(c) \(value)", "Answer \(c) \(value)", "no"])
                }
            }
        }
        rows.append(["final", "Final Cat", "", "Final clue", "Final answer", ""])
        return rows
    }

    private func importRows(_ rows: [[String]], title: String = "Test Game") throws -> [MacpardyBoard] {
        try CSVBoardImporter.importBoards(from: Data(CSVParser.write(rows).utf8), title: title)
    }

    private func issues(_ rows: [[String]]) -> [Issue] {
        issues(Data(CSVParser.write(rows).utf8))
    }

    private func issues(_ data: Data) -> [Issue] {
        do {
            _ = try CSVBoardImporter.importBoards(from: data, title: "Test")
            XCTFail("Expected the import to fail")
            return []
        } catch let error as CSVBoardImporter.ImportError {
            return error.issues
        } catch {
            XCTFail("Unexpected error \(error)")
            return []
        }
    }

    private func issue(_ row: Int?, _ column: CSVBoardImporter.Column?, _ kind: CSVBoardImporter.Kind) -> Issue {
        Issue(row: row, column: column, kind: kind)
    }

    // MARK: - Valid files

    func testValidFileBuildsThreeBoards() throws {
        let boards = try importRows(validRows())
        XCTAssertEqual(boards.map(\.round), [.macpardy, .doubleMacpardy, .finalMacpardy])
        XCTAssertEqual(boards.map(\.title), ["Test Game - Macpardy", "Test Game - Double Macpardy", "Test Game - Final Macpardy"])
        XCTAssertEqual(boards[0].categories.count, 6)
        XCTAssertEqual(boards[1].categories.count, 6)
        XCTAssertEqual(boards[0].categories[0].title, "single cat 1")
        XCTAssertEqual(boards[0].categories[0].questions.map(\.value), [200, 400, 600, 800, 1000])
        XCTAssertEqual(boards[1].categories[5].questions.map(\.value), [400, 800, 1200, 1600, 2000])
        XCTAssertEqual(boards[0].categories[2].questions[1].clue, "Clue single 3 400")
        XCTAssertEqual(boards[0].categories[2].questions[1].response, "Answer 3 400")
        XCTAssertEqual(boards[2].categories.count, 1)
        XCTAssertEqual(boards[2].categories[0].title, "Final Cat")
        XCTAssertEqual(boards[2].categories[0].questions.map(\.value), [0])
        XCTAssertEqual(boards[2].categories[0].questions[0].clue, "Final clue")
    }

    func testRowOrderDoesNotMatterAndValuesAreSorted() throws {
        var rows = validRows()
        let body = Array(rows.dropFirst()).reversed()
        rows = [header] + body
        let boards = try importRows(rows)
        XCTAssertEqual(boards[0].categories.map(\.title).first, "single cat 6")
        XCTAssertEqual(boards[0].categories[0].questions.map(\.value), [200, 400, 600, 800, 1000])
    }

    func testDailyDoubleFlags() throws {
        var rows = validRows()
        rows[1][5] = "YES"
        rows[2][5] = "true"
        rows[3][5] = "1"
        rows[4][5] = ""
        let questions = try importRows(rows)[0].categories[0].questions
        XCTAssertEqual(questions.map(\.isDailyDouble), [true, true, true, false, false])
    }

    func testHeadersAreCaseInsensitiveAndColumnsCanBeReordered() throws {
        let rows = validRows().map { row in [row[5], row[3], row[4], row[0], row[2], row[1]] }
        var shuffled = rows
        shuffled[0] = ["Daily_Double", " QUESTION ", "Answer", "Round", "Value", "Category"]
        let boards = try importRows(shuffled)
        XCTAssertEqual(boards[0].categories[0].questions[0].clue, "Clue single 1 200")
    }

    func testExtraColumnsAndBlankRowsAreIgnored() throws {
        var rows = validRows().map { $0 + [""] }
        rows[0][6] = "notes"
        rows.insert(["", "", "", "", "", "", ""], at: 5)
        rows.append(Array(repeating: "", count: 7))
        XCTAssertNoThrow(try importRows(rows))
    }

    func testQuotedCommasAndNewlinesInCells() throws {
        var rows = validRows()
        rows[1][3] = "Line one, with a comma\nLine \"two\""
        let boards = try importRows(rows)
        XCTAssertEqual(boards[0].categories[0].questions[0].clue, "Line one, with a comma\nLine \"two\"")
    }

    func testBOMAndNonEnglishText() throws {
        var rows = validRows()
        for index in 1...5 { rows[index][1] = "Géographie" }
        rows[2][1] = "géographie" // same category, matched case-insensitively
        rows[1][3] = "日本の首都は？"
        rows[1][4] = "¿Qué es Tokio?"
        let data = Data([0xEF, 0xBB, 0xBF]) + Data(CSVParser.write(rows).utf8)
        let boards = try CSVBoardImporter.importBoards(from: data, title: "Jeu")
        XCTAssertEqual(boards[0].categories[0].title, "Géographie")
        XCTAssertEqual(boards[0].categories[0].questions[0].clue, "日本の首都は？")
        XCTAssertEqual(boards[0].categories[0].questions[0].response, "¿Qué es Tokio?")
    }

    func testDollarAndThousandsFormattedValues() throws {
        var rows = validRows()
        rows[5][2] = "$1,000"
        XCTAssertNoThrow(try importRows(rows))
    }

    func testTemplateImportsCleanly() throws {
        let boards = try CSVBoardImporter.importBoards(from: CSVBoardTemplate.makeData(), title: "Template")
        XCTAssertEqual(boards.count, 3)
        XCTAssertEqual(boards[0].categories.map(\.title), (1...6).map { BoardDefaults.categoryTitle($0) })
        XCTAssertEqual(boards[2].categories.first?.title, BoardDefaults.finalCategory)
        XCTAssertEqual(boards[0].categories.flatMap(\.questions).filter(\.isDailyDouble).count, 1)
        XCTAssertEqual(boards[1].categories.flatMap(\.questions).filter(\.isDailyDouble).count, 2)
    }

    func testTemplateMatchesTheEditorsDefaults() throws {
        let boards = try CSVBoardImporter.importBoards(from: CSVBoardTemplate.makeData(), title: "Template")
        let draft = BoardDefaults.makeDraft()
        XCTAssertEqual(
            boards[0].categories.map { $0.questions.map(\.clue) },
            draft.makeBoards()[0].categories.map { $0.questions.map(\.clue) }
        )
        XCTAssertEqual(
            boards[1].categories.map { $0.questions.map(\.isDailyDouble) },
            draft.makeBoards()[1].categories.map { $0.questions.map(\.isDailyDouble) }
        )
    }

    func testUntouchedTemplateWarnsAboutEveryDefaultCell() {
        let warnings = CSVBoardImporter.defaultTextWarnings(from: CSVBoardTemplate.makeData())
        // 12 categories (once each) + 60 clues + 60 answers + 3 final cells.
        XCTAssertEqual(warnings.count, 12 + 60 + 60 + 3)
        XCTAssertTrue(warnings.allSatisfy { $0.kind == .defaultText })
        // Row 2 is the first clue of the first category.
        XCTAssertEqual(
            warnings.prefix(3).map { [$0.row, $0.column.map(\.rawValue)] as [AnyHashable?] },
            [[2, "category"], [2, "question"], [2, "answer"]]
        )
        XCTAssertNotNil(warnings[0].location)
        XCTAssertFalse(warnings[0].message.isEmpty)
    }

    func testEditedCellsAreNotWarnedAbout() {
        var rows = CSVBoardTemplate.makeRows()
        rows[1][3] = "A real clue"          // row 2: question
        rows[1][1] = "Science"              // row 2: category title
        let data = Data(CSVParser.write(rows).utf8)
        let warnings = CSVBoardImporter.defaultTextWarnings(from: data)
        XCTAssertFalse(warnings.contains { $0.row == 2 && $0.column == .question })
        XCTAssertTrue(warnings.contains { $0.row == 2 && $0.column == .answer })
    }

    func testFileWithoutDefaultTextHasNoWarnings() {
        let data = Data(CSVParser.write(validRows()).utf8)
        XCTAssertTrue(CSVBoardImporter.defaultTextWarnings(from: data).isEmpty)
    }

    func testSavedJSONReopensThroughBoardLoader() throws {
        let boards = try importRows(validRows())
        let json = try MacpardyJSONBoardDocument.encode(boards)
        XCTAssertFalse(BoardPackage.isZip(json))
        XCTAssertEqual(try BoardPackage.read(json), boards)
        XCTAssertEqual(try MacpardyBoardsDocument.decodeBoards(from: json), boards)
    }

    // MARK: - File-level errors

    func testEmptyFile() {
        XCTAssertEqual(issues(Data()), [issue(nil, nil, .emptyFile)])
        XCTAssertEqual(issues(Data("\n\n".utf8)), [issue(nil, nil, .emptyFile)])
    }

    func testNotUTF8() {
        XCTAssertEqual(issues(Data([0x72, 0xFF, 0x0A])), [issue(nil, nil, .notUTF8)])
    }

    func testUnclosedQuote() {
        let text = CSVParser.write(validRows()) + "single,\"never closed\n"
        XCTAssertEqual(issues(Data(text.utf8)), [issue(63, nil, .unclosedQuote)])
    }

    func testMissingAndDuplicateColumns() {
        var rows = validRows()
        rows[0] = ["round", "category", "category", "question", "notes", "daily_double"]
        XCTAssertEqual(issues(rows), [
            issue(1, .category, .duplicateColumn),
            issue(1, .value, .missingColumn),
            issue(1, .answer, .missingColumn),
        ])
    }

    // MARK: - Cell errors

    func testEmptyCellsAreReportedWithRowAndColumn() {
        var rows = validRows()
        rows[3][3] = "  "
        rows[3][4] = ""
        let found = issues(rows)
        XCTAssertEqual(found, [issue(4, .question, .emptyCell), issue(4, .answer, .emptyCell)])
    }

    func testBadValues() {
        var rows = validRows()
        rows[1][2] = "two hundred"   // row 2: single cat 1, 200
        rows[7][2] = "300"           // row 8: single cat 2, 400 → not allowed
        rows[11][5] = "maybe"        // row 12: single cat 3, 200
        rows[31][0] = "triple"       // row 32: first double row
        let found = issues(rows)
        XCTAssertTrue(found.contains(issue(2, .value, .notANumber("two hundred"))))
        XCTAssertTrue(found.contains(issue(8, .value, .valueNotAllowed(300, allowed: [200, 400, 600, 800, 1000]))))
        XCTAssertTrue(found.contains(issue(12, .dailyDouble, .badDailyDouble("maybe"))))
        XCTAssertTrue(found.contains(issue(32, .round, .unknownRound("triple"))))
        XCTAssertTrue(found.contains(issue(33, .value, .missingValues(category: "double cat 1", values: [400]))))
        // The clues those cells belonged to are now missing from their categories.
        XCTAssertTrue(found.contains(issue(2, .value, .missingValues(category: "single cat 1", values: [200]))))
        XCTAssertTrue(found.contains(issue(7, .value, .missingValues(category: "single cat 2", values: [400]))))
    }

    func testDuplicateValueInCategory() {
        var rows = validRows()
        rows[2][2] = "200" // row 3: single cat 1 now has two 200s and no 400
        XCTAssertEqual(issues(rows), [
            issue(2, .value, .missingValues(category: "single cat 1", values: [400])),
            issue(3, .value, .duplicateValue(200)),
        ])
    }

    func testWrongNumberOfCategories() {
        // Drop "double cat 6" entirely.
        let rows = validRows().filter { $0[1] != "double cat 6" }
        XCTAssertEqual(issues(rows), [
            issue(32, .category, .wrongCategoryCount(round: "double", found: 5, expected: 6)),
        ])
    }

    func testSeventhCategory() {
        var rows = validRows()
        rows.insert(["single", "Bonus", "200", "q", "a", ""], at: 31)
        let found = issues(rows)
        XCTAssertTrue(found.contains(issue(2, .category, .wrongCategoryCount(round: "single", found: 7, expected: 6))))
        XCTAssertTrue(found.contains(issue(32, .value, .missingValues(category: "Bonus", values: [400, 600, 800, 1000]))))
    }

    func testMissingRounds() {
        let rows = validRows().filter { $0[0] != "double" && $0[0] != "final" }
        XCTAssertEqual(issues(rows), [
            issue(31, .round, .missingRound("double")),
            issue(31, .round, .missingRound("final")),
        ])
    }

    func testMoreThanOneFinal() {
        var rows = validRows()
        rows.append(["Final", "Another", "", "q", "a", ""])
        XCTAssertEqual(issues(rows), [issue(63, .round, .duplicateFinal)])
    }

    func testFinalWithValueOrDailyDouble() {
        var rows = validRows()
        rows[61][2] = "500"
        rows[61][5] = "yes"
        XCTAssertEqual(issues(rows), [
            issue(62, .value, .finalHasValue),
            issue(62, .dailyDouble, .finalIsDailyDouble),
        ])
    }

    func testExtraCellsBeyondHeader() {
        var rows = validRows()
        rows[10].append("stray")
        XCTAssertEqual(issues(rows), [issue(11, nil, .extraCells)])
    }

    func testAllErrorsAreReportedNotJustTheFirst() {
        var rows = validRows()
        rows[1][3] = ""
        rows[20][4] = ""
        rows[40][2] = "abc"
        rows[61][5] = "yes"
        XCTAssertEqual(issues(rows), [
            issue(2, .question, .emptyCell),
            issue(21, .answer, .emptyCell),
            issue(37, .value, .missingValues(category: "double cat 2", values: [2000])),
            issue(41, .value, .notANumber("abc")),
            issue(62, .dailyDouble, .finalIsDailyDouble),
        ])
    }

    func testIssuesHaveLocalizedMessagesAndLocations() {
        let sample = issue(4, .question, .emptyCell)
        XCTAssertFalse(sample.message.isEmpty)
        XCTAssertNotNil(sample.location)
        XCTAssertNil(issue(nil, nil, .emptyFile).location)
    }
}
