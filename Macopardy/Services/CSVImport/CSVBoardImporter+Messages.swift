//
//  CSVBoardImporter+Messages.swift
//  Macopardy
//

import Foundation

extension CSVBoardImporter.Issue {

    /// Where the problem is, e.g. "Row 4, column “question”". `nil` for
    /// problems with the whole file.
    var location: String? {
        switch (row, column) {
        case let (row?, column?):
            String(localized: "csv.error.location.row_column \(row) \(column.rawValue)")
        case let (row?, nil):
            String(localized: "csv.error.location.row \(row)")
        case let (nil, column?):
            String(localized: "csv.error.location.column \(column.rawValue)")
        case (nil, nil):
            nil
        }
    }

    /// What's wrong, in the user's language.
    var message: String {
        switch kind {
        case .emptyFile:
            String(localized: "csv.error.empty_file")
        case .notUTF8:
            String(localized: "csv.error.not_utf8")
        case .unclosedQuote:
            String(localized: "csv.error.unclosed_quote")
        case .textAfterQuote:
            String(localized: "csv.error.text_after_quote")
        case .missingColumn:
            String(localized: "csv.error.missing_column")
        case .duplicateColumn:
            String(localized: "csv.error.duplicate_column")
        case .extraCells:
            String(localized: "csv.error.extra_cells")
        case .emptyCell:
            String(localized: "csv.error.empty_cell")
        case .unknownRound(let text):
            String(localized: "csv.error.unknown_round \(text)")
        case .notANumber(let text):
            String(localized: "csv.error.not_a_number \(text)")
        case .valueNotAllowed(let value, let allowed):
            String(localized: "csv.error.value_not_allowed \(value) \(Self.list(allowed))")
        case .duplicateValue(let value):
            String(localized: "csv.error.duplicate_value \(value)")
        case .badDailyDouble(let text):
            String(localized: "csv.error.bad_daily_double \(text)")
        case .missingValues(let category, let values):
            String(localized: "csv.error.missing_values \(category) \(Self.list(values))")
        case .wrongCategoryCount(let round, let found, let expected):
            String(localized: "csv.error.wrong_category_count \(round) \(found) \(expected)")
        case .missingRound(let round):
            String(localized: "csv.error.missing_round \(round)")
        case .duplicateFinal:
            String(localized: "csv.error.duplicate_final")
        case .finalHasValue:
            String(localized: "csv.error.final_has_value")
        case .finalIsDailyDouble:
            String(localized: "csv.error.final_is_daily_double")
        }
    }

    private static func list(_ values: [Int]) -> String {
        values.map(String.init).formatted(.list(type: .and))
    }
}
