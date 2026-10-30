//
//  CSVParser.swift
//  Macopardy
//

import Foundation

/// A minimal RFC 4180 CSV reader.
///
/// - Input must be UTF-8. A leading byte-order mark is skipped.
/// - Fields may be quoted with `"`. Quoted fields can contain commas, line
///   breaks, and doubled quotes (`""` → `"`).
/// - Records end with `\n`, `\r\n`, or `\r` outside quotes.
/// - A trailing line break at the end of the file doesn't start a new record.
enum CSVParser {

    /// One record (spreadsheet row). `row` is 1-based and counts records, so it
    /// matches the row number a spreadsheet app shows even when a cell
    /// contains line breaks.
    struct Record: Equatable {
        let row: Int
        let fields: [String]
    }

    enum ParseError: Error, Equatable {
        /// The bytes aren't valid UTF-8.
        case notUTF8
        /// A quoted field is still open at the end of the file. `row` is the
        /// record the quote started in.
        case unclosedQuote(row: Int)
        /// Characters after a closing quote, before the next comma or line
        /// break (e.g. `"abc"def`).
        case unexpectedCharacterAfterQuote(row: Int)
    }

    private static let utf8BOM: [UInt8] = [0xEF, 0xBB, 0xBF]

    static func parse(_ data: Data) throws -> [Record] {
        let bytes = data.starts(with: utf8BOM) ? data.dropFirst(utf8BOM.count) : data[...]
        guard let text = String(data: Data(bytes), encoding: .utf8) else {
            throw ParseError.notUTF8
        }
        return try parse(text)
    }

    static func parse(_ text: String) throws -> [Record] {
        var text = Substring(text)
        if text.unicodeScalars.first == "\u{FEFF}" {
            text = Substring(text.unicodeScalars.dropFirst())
        }

        var records: [Record] = []
        var fields: [String] = []
        var field = String.UnicodeScalarView()
        var inQuotes = false
        var fieldWasQuoted = false
        var quoteStartRow = 1
        var recordHasContent = false

        func endField() {
            fields.append(String(field))
            field = String.UnicodeScalarView()
            fieldWasQuoted = false
        }

        func endRecord() {
            endField()
            records.append(Record(row: records.count + 1, fields: fields))
            fields = []
            recordHasContent = false
        }

        let scalars = Array(text.unicodeScalars)
        var i = 0
        while i < scalars.count {
            let c = scalars[i]

            if inQuotes {
                if c == "\"" {
                    if i + 1 < scalars.count, scalars[i + 1] == "\"" {
                        field.append("\"")
                        i += 2
                        continue
                    }
                    inQuotes = false
                } else {
                    field.append(c)
                }
                i += 1
                continue
            }

            switch c {
            case "\"":
                if field.isEmpty && !fieldWasQuoted {
                    inQuotes = true
                    fieldWasQuoted = true
                    quoteStartRow = records.count + 1
                    recordHasContent = true
                } else if fieldWasQuoted {
                    throw ParseError.unexpectedCharacterAfterQuote(row: records.count + 1)
                } else {
                    // A stray quote inside an unquoted field is kept as-is,
                    // which is what spreadsheet apps do.
                    field.append(c)
                }
            case ",":
                endField()
                recordHasContent = true
            case "\r":
                endRecord()
                if i + 1 < scalars.count, scalars[i + 1] == "\n" { i += 1 }
            case "\n":
                endRecord()
            default:
                if fieldWasQuoted {
                    throw ParseError.unexpectedCharacterAfterQuote(row: records.count + 1)
                }
                field.append(c)
                recordHasContent = true
            }
            i += 1
        }

        if inQuotes {
            throw ParseError.unclosedQuote(row: quoteStartRow)
        }
        if recordHasContent || !field.isEmpty {
            endRecord()
        }
        return records
    }

    /// Escapes a value for writing: quoted only when it needs to be.
    static func escape(_ value: String) -> String {
        let needsQuotes = value.unicodeScalars.contains { $0 == "," || $0 == "\"" || $0 == "\n" || $0 == "\r" }
        guard needsQuotes else { return value }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    /// Joins rows into CSV text with `\r\n` line endings (RFC 4180).
    static func write(_ rows: [[String]]) -> String {
        rows.map { $0.map(escape).joined(separator: ",") }.joined(separator: "\r\n") + "\r\n"
    }
}
