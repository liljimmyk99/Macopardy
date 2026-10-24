//
//  CSVBoardTemplate.swift
//  Macopardy
//

import Foundation

/// The CSV a user downloads to start a game in a spreadsheet.
///
/// It's a complete, importable game: the sample categories for the first
/// round, placeholders for Double Macpardy, and one Final Macpardy row. The
/// user replaces the text and uploads it.
enum CSVBoardTemplate {

    static let suggestedFileName = "macopardy-template.csv"

    static func makeRows() -> [[String]] {
        typealias Column = CSVBoardImporter.Column
        typealias RoundName = CSVBoardImporter.RoundName

        var rows: [[String]] = [Column.allCases.map(\.rawValue)]

        // First round: the built-in sample board, with one Daily Double.
        for (categoryIndex, category) in MacpardyBoard.sample.categories.enumerated() {
            for (questionIndex, question) in category.questions.enumerated() {
                let isDailyDouble = categoryIndex == 2 && questionIndex == 3
                rows.append([
                    RoundName.single.rawValue,
                    category.title,
                    String(question.value),
                    question.clue,
                    question.response,
                    isDailyDouble ? "yes" : "no",
                ])
            }
        }

        // Double Macpardy: placeholders, with two Daily Doubles.
        let doubleValues = CSVBoardImporter.values(for: .double)
        for (categoryIndex, title) in CreateMacpardyGameView.round2DefaultCategories.enumerated() {
            for (questionIndex, value) in doubleValues.enumerated() {
                let isDailyDouble = (categoryIndex == 1 && questionIndex == 2) || (categoryIndex == 4 && questionIndex == 4)
                rows.append([
                    RoundName.double.rawValue,
                    title,
                    String(value),
                    "Replace with your \(title) clue for \(value)",
                    "Replace with the response",
                    isDailyDouble ? "yes" : "no",
                ])
            }
        }

        rows.append([
            RoundName.finalRound.rawValue,
            "World Capitals",
            "",
            "This capital city sits on both banks of the Danube, which once divided its two halves.",
            "What is Budapest?",
            "",
        ])

        return rows
    }

    /// UTF-8 with a byte-order mark, so Excel reads non-English text correctly.
    static func makeData() -> Data {
        Data([0xEF, 0xBB, 0xBF]) + Data(CSVParser.write(makeRows()).utf8)
    }
}
