//
//  CSVBoardTemplate.swift
//  Macopardy
//

import Foundation

/// The CSV a user downloads to start a game in a spreadsheet.
///
/// It's a complete, importable game built from `BoardDefaults`, the same
/// content a new game in the editor starts with: both rounds, their Daily
/// Doubles, and one Final Macpardy row. The user replaces the text and
/// uploads it.
enum CSVBoardTemplate {

    static let suggestedFileName = "macopardy-template.csv"

    static func makeRows() -> [[String]] {
        typealias Column = CSVBoardImporter.Column
        typealias RoundName = CSVBoardImporter.RoundName

        var rows: [[String]] = [Column.allCases.map(\.rawValue)]

        for (roundNumber, roundName) in [(1, RoundName.single), (2, RoundName.double)] {
            for category in BoardDefaults.makeCategories(round: roundNumber) {
                for question in category.questions {
                    rows.append([
                        roundName.rawValue,
                        category.title,
                        String(question.value),
                        question.clue,
                        question.response,
                        question.isDailyDouble ? "yes" : "no",
                    ])
                }
            }
        }

        rows.append([
            RoundName.finalRound.rawValue,
            BoardDefaults.finalCategory,
            "",
            BoardDefaults.finalClue,
            BoardDefaults.finalAnswer,
            "",
        ])

        return rows
    }

    /// UTF-8 with a byte-order mark, so Excel reads non-English text correctly.
    static func makeData() -> Data {
        Data([0xEF, 0xBB, 0xBF]) + Data(CSVParser.write(makeRows()).utf8)
    }
}
