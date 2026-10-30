//
//  CSVParserTests.swift
//  MacpardyTests
//

import XCTest
@testable import Macpardy

@MainActor
final class CSVParserTests: XCTestCase {

    private func fields(_ text: String) throws -> [[String]] {
        try CSVParser.parse(text).map(\.fields)
    }

    func testSimpleRows() throws {
        XCTAssertEqual(try fields("a,b,c\n1,2,3\n"), [["a", "b", "c"], ["1", "2", "3"]])
    }

    func testNoTrailingNewline() throws {
        XCTAssertEqual(try fields("a,b\n1,2"), [["a", "b"], ["1", "2"]])
    }

    func testCRLFAndCR() throws {
        XCTAssertEqual(try fields("a,b\r\n1,2\r3,4\r\n"), [["a", "b"], ["1", "2"], ["3", "4"]])
    }

    func testQuotedCommasQuotesAndNewlines() throws {
        let text = "q,a\n\"Hello, world\",\"She said \"\"hi\"\"\"\n\"line one\nline two\",x\n"
        XCTAssertEqual(try fields(text), [
            ["q", "a"],
            ["Hello, world", "She said \"hi\""],
            ["line one\nline two", "x"],
        ])
    }

    func testRowNumbersCountRecordsNotLines() throws {
        let records = try CSVParser.parse("h\n\"a\nb\"\nc\n")
        XCTAssertEqual(records.map(\.row), [1, 2, 3])
        XCTAssertEqual(records[2].fields, ["c"])
    }

    func testEmptyFieldsAndEmptyQuotedField() throws {
        XCTAssertEqual(try fields("a,,\"\",d\n"), [["a", "", "", "d"]])
    }

    func testBOMIsSkipped() throws {
        let data = Data([0xEF, 0xBB, 0xBF]) + Data("round,category\n".utf8)
        XCTAssertEqual(try CSVParser.parse(data).map(\.fields), [["round", "category"]])
    }

    func testInvalidUTF8() {
        let data = Data([0x61, 0x2C, 0xFF, 0xFE, 0x0A])
        XCTAssertThrowsError(try CSVParser.parse(data)) { error in
            XCTAssertEqual(error as? CSVParser.ParseError, .notUTF8)
        }
    }

    func testUnclosedQuoteReportsStartingRow() {
        XCTAssertThrowsError(try CSVParser.parse("a\nb\n\"open\nstill open\n")) { error in
            XCTAssertEqual(error as? CSVParser.ParseError, .unclosedQuote(row: 3))
        }
    }

    func testTextAfterClosingQuote() {
        XCTAssertThrowsError(try CSVParser.parse("a\n\"abc\"def\n")) { error in
            XCTAssertEqual(error as? CSVParser.ParseError, .unexpectedCharacterAfterQuote(row: 2))
        }
    }

    func testNonEnglishText() throws {
        XCTAssertEqual(try fields("¿Qué?,日本語,Ελληνικά,🎉\n"), [["¿Qué?", "日本語", "Ελληνικά", "🎉"]])
    }

    func testWriteRoundTrips() throws {
        let rows = [["a", "b,c"], ["\"quoted\"", "line\nbreak"], ["", "plain"]]
        XCTAssertEqual(try fields(CSVParser.write(rows)), rows)
    }
}
