//
//  CSVBoardImporter.swift
//  Macopardy
//

import Foundation

/// Turns a CSV file into a game's boards (Macpardy, Double Macpardy, Final).
///
/// The layout is one row per clue; see `docs/csv-import.md`. Every problem in
/// the file is collected, so the user can fix them all in one pass. If there
/// are any, nothing is imported.
enum CSVBoardImporter {

    // MARK: - Schema

    /// Column headers. Fixed English identifiers; not localized.
    enum Column: String, CaseIterable {
        case round
        case category
        case value
        case question
        case answer
        case dailyDouble = "daily_double"
    }

    /// Values allowed in the `round` column (case-insensitive).
    enum RoundName: String, CaseIterable {
        case single
        case double
        case finalRound = "final"

        var round: MacpardyRound {
            switch self {
            case .single: .macpardy
            case .double: .doubleMacpardy
            case .finalRound: .finalMacpardy
            }
        }
    }

    /// Categories per round, matching the game editor.
    static let categoriesPerRound = 6

    /// Point values for each clue in a category, matching the game editor.
    static func values(for round: RoundName) -> [Int] {
        switch round {
        case .single: BoardDefaults.round1Values
        case .double: BoardDefaults.round2Values
        case .finalRound: []
        }
    }

    static let yesValues: Set<String> = ["yes", "y", "true", "1", "x"]
    static let noValues: Set<String> = ["no", "n", "false", "0", ""]

    // MARK: - Errors

    /// One problem in the file. `row` is the spreadsheet row (the header is
    /// row 1) and `column` the column header, when the problem is in a cell.
    struct Issue: Equatable, Identifiable {
        let id = UUID()
        let row: Int?
        let column: Column?
        let kind: Kind

        static func == (lhs: Issue, rhs: Issue) -> Bool {
            lhs.row == rhs.row && lhs.column == rhs.column && lhs.kind == rhs.kind
        }
    }

    enum Kind: Equatable {
        /// The file has no header row.
        case emptyFile
        /// The file isn't UTF-8 text.
        case notUTF8
        /// A quoted cell is never closed.
        case unclosedQuote
        /// Text follows a closing quote inside a cell.
        case textAfterQuote
        /// A required column header is missing.
        case missingColumn
        /// A column header appears more than once.
        case duplicateColumn
        /// The row has filled cells to the right of the last column.
        case extraCells
        /// A required cell is empty.
        case emptyCell
        /// The `round` cell isn't single, double, or final.
        case unknownRound(String)
        /// The `value` cell isn't a whole number.
        case notANumber(String)
        /// The value isn't one of the round's point values.
        case valueNotAllowed(Int, allowed: [Int])
        /// The category already has a clue with this value.
        case duplicateValue(Int)
        /// The `daily_double` cell isn't yes or no.
        case badDailyDouble(String)
        /// The category is missing clues for these values.
        case missingValues(category: String, values: [Int])
        /// The round has the wrong number of categories.
        case wrongCategoryCount(round: String, found: Int, expected: Int)
        /// No rows for this round.
        case missingRound(String)
        /// More than one Final Macpardy row.
        case duplicateFinal
        /// The Final Macpardy row has a value.
        case finalHasValue
        /// The Final Macpardy row is marked as a Daily Double.
        case finalIsDailyDouble
        /// The cell still holds the template's default text. Only reported
        /// as a warning by `defaultTextWarnings`; it never blocks an import.
        case defaultText
    }

    enum ImportError: Error {
        case invalid([Issue])

        var issues: [Issue] {
            switch self {
            case .invalid(let issues): issues
            }
        }
    }

    // MARK: - Import

    /// Parses `data` and builds the game's three boards. `title` names the
    /// game (the app uses the CSV's file name).
    ///
    /// - Throws: `ImportError.invalid` listing every problem found.
    static func importBoards(from data: Data, title: String) throws -> [MacpardyBoard] {
        let records: [CSVParser.Record]
        do {
            records = try CSVParser.parse(data)
        } catch let error as CSVParser.ParseError {
            throw ImportError.invalid([issue(for: error)])
        }
        return try importBoards(from: records, title: title)
    }

    static func importBoards(from records: [CSVParser.Record], title: String) throws -> [MacpardyBoard] {
        var issues: [Issue] = []

        guard let header = records.first,
              header.fields.contains(where: { !trim($0).isEmpty }) else {
            throw ImportError.invalid([Issue(row: nil, column: nil, kind: .emptyFile)])
        }

        // Header
        var columnIndex: [Column: Int] = [:]
        for (index, name) in header.fields.enumerated() {
            guard let column = Column(rawValue: trim(name).lowercased()) else { continue }
            if columnIndex[column] != nil {
                issues.append(Issue(row: header.row, column: column, kind: .duplicateColumn))
            } else {
                columnIndex[column] = index
            }
        }
        for column in Column.allCases where columnIndex[column] == nil {
            issues.append(Issue(row: header.row, column: column, kind: .missingColumn))
        }
        guard issues.isEmpty else { throw ImportError.invalid(issues) }

        let lastColumnIndex = header.fields.count - 1

        // Rows
        var rounds: [RoundName: RoundDraft] = [:]
        var finalRows: [(row: Int, category: String, clue: String, response: String)] = []

        for record in records.dropFirst() {
            // Spreadsheet apps often leave empty rows; skip them.
            if record.fields.allSatisfy({ trim($0).isEmpty }) { continue }

            let row = record.row
            func cell(_ column: Column) -> String {
                let index = columnIndex[column]!
                return index < record.fields.count ? trim(record.fields[index]) : ""
            }

            if record.fields.count > lastColumnIndex + 1,
               record.fields[(lastColumnIndex + 1)...].contains(where: { !trim($0).isEmpty }) {
                issues.append(Issue(row: row, column: nil, kind: .extraCells))
            }

            let roundText = cell(.round)
            let category = cell(.category)
            let clue = cell(.question)
            let response = cell(.answer)
            let valueText = cell(.value)
            let dailyDoubleText = cell(.dailyDouble)

            var rowIssues: [Issue] = []
            if category.isEmpty { rowIssues.append(Issue(row: row, column: .category, kind: .emptyCell)) }
            if clue.isEmpty { rowIssues.append(Issue(row: row, column: .question, kind: .emptyCell)) }
            if response.isEmpty { rowIssues.append(Issue(row: row, column: .answer, kind: .emptyCell)) }

            let roundName: RoundName?
            if roundText.isEmpty {
                rowIssues.append(Issue(row: row, column: .round, kind: .emptyCell))
                roundName = nil
            } else if let name = RoundName(rawValue: roundText.lowercased()) {
                roundName = name
            } else {
                rowIssues.append(Issue(row: row, column: .round, kind: .unknownRound(roundText)))
                roundName = nil
            }

            let dailyDouble: Bool?
            switch dailyDoubleText.lowercased() {
            case let text where yesValues.contains(text): dailyDouble = true
            case let text where noValues.contains(text): dailyDouble = false
            default:
                rowIssues.append(Issue(row: row, column: .dailyDouble, kind: .badDailyDouble(dailyDoubleText)))
                dailyDouble = nil
            }

            guard let roundName else {
                issues += rowIssues
                continue
            }

            if roundName == .finalRound {
                if !valueText.isEmpty && valueText != "0" {
                    rowIssues.append(Issue(row: row, column: .value, kind: .finalHasValue))
                }
                if dailyDouble == true {
                    rowIssues.append(Issue(row: row, column: .dailyDouble, kind: .finalIsDailyDouble))
                }
                if !finalRows.isEmpty {
                    rowIssues.append(Issue(row: row, column: .round, kind: .duplicateFinal))
                }
                finalRows.append((row, category, clue, response))
                issues += rowIssues
                continue
            }

            let allowed = values(for: roundName)
            var value: Int?
            if valueText.isEmpty {
                rowIssues.append(Issue(row: row, column: .value, kind: .emptyCell))
            } else if let number = parseNumber(valueText) {
                if allowed.contains(number) {
                    value = number
                } else {
                    rowIssues.append(Issue(row: row, column: .value, kind: .valueNotAllowed(number, allowed: allowed)))
                }
            } else {
                rowIssues.append(Issue(row: row, column: .value, kind: .notANumber(valueText)))
            }

            // Group by category even when other cells are bad, so count and
            // duplicate checks still run.
            if !category.isEmpty {
                var draft = rounds[roundName] ?? RoundDraft(firstRow: row)
                let categoryIndex = draft.categoryIndex(for: category, row: row)
                if let value {
                    if draft.categories[categoryIndex].clues[value] != nil {
                        rowIssues.append(Issue(row: row, column: .value, kind: .duplicateValue(value)))
                    } else {
                        draft.categories[categoryIndex].clues[value] = Question(
                            value: value,
                            clue: clue,
                            response: response,
                            isDailyDouble: dailyDouble ?? false
                        )
                    }
                }
                rounds[roundName] = draft
            } else if rounds[roundName] == nil {
                rounds[roundName] = RoundDraft(firstRow: row)
            }

            issues += rowIssues
        }

        // Round-level checks
        let lastRow = records.last?.row ?? 1
        for roundName in [RoundName.single, .double] {
            guard let draft = rounds[roundName] else {
                issues.append(Issue(row: lastRow, column: .round, kind: .missingRound(roundName.rawValue)))
                continue
            }
            if draft.categories.count != categoriesPerRound {
                issues.append(Issue(
                    row: draft.firstRow,
                    column: .category,
                    kind: .wrongCategoryCount(round: roundName.rawValue, found: draft.categories.count, expected: categoriesPerRound)
                ))
            }
            for category in draft.categories {
                let missing = values(for: roundName).filter { category.clues[$0] == nil }
                if !missing.isEmpty {
                    issues.append(Issue(
                        row: category.firstRow,
                        column: .value,
                        kind: .missingValues(category: category.title, values: missing)
                    ))
                }
            }
        }
        if finalRows.isEmpty {
            issues.append(Issue(row: lastRow, column: .round, kind: .missingRound(RoundName.finalRound.rawValue)))
        }

        guard issues.isEmpty,
              let single = rounds[.single],
              let double = rounds[.double],
              let finalRow = finalRows.first else {
            throw ImportError.invalid(sortedByLocation(issues))
        }

        let trimmedTitle = trim(title)
        return [
            MacpardyBoard(
                title: "\(trimmedTitle) - Macpardy",
                round: .macpardy,
                categories: single.makeCategories(values: values(for: .single))
            ),
            MacpardyBoard(
                title: "\(trimmedTitle) - Double Macpardy",
                round: .doubleMacpardy,
                categories: double.makeCategories(values: values(for: .double))
            ),
            MacpardyBoard(
                title: "\(trimmedTitle) - Final Macpardy",
                round: .finalMacpardy,
                categories: [
                    Category(
                        title: finalRow.category,
                        questions: [Question(value: 0, clue: finalRow.clue, response: finalRow.response)]
                    )
                ]
            ),
        ]
    }

    // MARK: - Default text

    /// Cells that still hold the default text from `BoardDefaults` (the
    /// downloaded template). Warnings only: the file is still a valid game.
    /// Returns nothing if the file can't be read as a game.
    ///
    /// A category cell is reported once, on the category's first row.
    static func defaultTextWarnings(from data: Data) -> [Issue] {
        guard let records = try? CSVParser.parse(data),
              let header = records.first else { return [] }

        var columnIndex: [Column: Int] = [:]
        for (index, name) in header.fields.enumerated() {
            if let column = Column(rawValue: trim(name).lowercased()), columnIndex[column] == nil {
                columnIndex[column] = index
            }
        }
        guard Column.allCases.allSatisfy({ columnIndex[$0] != nil }) else { return [] }

        var categoryOrder: [RoundName: [String]] = [:]
        var warnings: [Issue] = []

        for record in records.dropFirst() {
            func cell(_ column: Column) -> String {
                let index = columnIndex[column]!
                return index < record.fields.count ? trim(record.fields[index]) : ""
            }
            guard let roundName = RoundName(rawValue: cell(.round).lowercased()) else { continue }

            let category = cell(.category)
            let clue = cell(.question)
            let response = cell(.answer)

            if roundName == .finalRound {
                if category == trim(BoardDefaults.finalCategory) { warnings.append(Issue(row: record.row, column: .category, kind: .defaultText)) }
                if clue == trim(BoardDefaults.finalClue) { warnings.append(Issue(row: record.row, column: .question, kind: .defaultText)) }
                if response == trim(BoardDefaults.finalAnswer) { warnings.append(Issue(row: record.row, column: .answer, kind: .defaultText)) }
                continue
            }

            guard !category.isEmpty, let value = parseNumber(cell(.value)) else { continue }

            var categories = categoryOrder[roundName] ?? []
            let isNewCategory: Bool
            let index: Int
            if let existing = categories.firstIndex(where: { $0.caseInsensitiveCompare(category) == .orderedSame }) {
                index = existing
                isNewCategory = false
            } else {
                categories.append(category)
                index = categories.count - 1
                isNewCategory = true
            }
            categoryOrder[roundName] = categories

            let number = index + 1
            if isNewCategory, category == trim(BoardDefaults.categoryTitle(number)) {
                warnings.append(Issue(row: record.row, column: .category, kind: .defaultText))
            }
            if clue == trim(BoardDefaults.clue(category: number, value: value)) {
                warnings.append(Issue(row: record.row, column: .question, kind: .defaultText))
            }
            if response == trim(BoardDefaults.answer(category: number, value: value)) {
                warnings.append(Issue(row: record.row, column: .answer, kind: .defaultText))
            }
        }

        return warnings
    }

    // MARK: - Helpers

    private struct CategoryDraft {
        let title: String
        let firstRow: Int
        var clues: [Int: Question] = [:]
    }

    private struct RoundDraft {
        let firstRow: Int
        var categories: [CategoryDraft] = []

        /// Categories are matched by title, ignoring case, in order of first appearance.
        mutating func categoryIndex(for title: String, row: Int) -> Int {
            if let index = categories.firstIndex(where: { $0.title.caseInsensitiveCompare(title) == .orderedSame }) {
                return index
            }
            categories.append(CategoryDraft(title: title, firstRow: row))
            return categories.count - 1
        }

        func makeCategories(values: [Int]) -> [Category] {
            categories.map { draft in
                Category(title: draft.title, questions: values.compactMap { draft.clues[$0] })
            }
        }
    }

    private static func trim(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Accepts whole numbers, optionally with a leading `$` or thousands
    /// separators (`$1,000`), since spreadsheets often format them that way.
    private static func parseNumber(_ text: String) -> Int? {
        var cleaned = text
        if cleaned.hasPrefix("$") { cleaned.removeFirst() }
        cleaned = cleaned.replacingOccurrences(of: ",", with: "")
        if cleaned.hasSuffix(".0") { cleaned.removeLast(2) }
        return Int(cleaned)
    }

    private static func issue(for error: CSVParser.ParseError) -> Issue {
        switch error {
        case .notUTF8:
            Issue(row: nil, column: nil, kind: .notUTF8)
        case .unclosedQuote(let row):
            Issue(row: row, column: nil, kind: .unclosedQuote)
        case .unexpectedCharacterAfterQuote(let row):
            Issue(row: row, column: nil, kind: .textAfterQuote)
        }
    }

    /// Sorts by row, then column order, keeping the original order for ties.
    /// File-level issues come first.
    private static func sortedByLocation(_ issues: [Issue]) -> [Issue] {
        func key(_ issue: Issue) -> (Int, Int) {
            (issue.row ?? 0, issue.column.flatMap { Column.allCases.firstIndex(of: $0) } ?? -1)
        }
        return issues.enumerated()
            .sorted { lhs, rhs in
                let (l, r) = (key(lhs.element), key(rhs.element))
                return l != r ? l < r : lhs.offset < rhs.offset
            }
            .map(\.element)
    }
}
