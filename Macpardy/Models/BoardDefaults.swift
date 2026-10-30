//
//  BoardDefaults.swift
//  Macopardy
//

import Foundation

/// The content every new board starts with.
///
/// This is the single definition shared by the game editor, the CSV template,
/// and the checks that tell whether a field still holds default text. A new
/// board built from these values is complete and playable as it is.
enum BoardDefaults {

    static let round1Values = [200, 400, 600, 800, 1000]
    static let round2Values = [400, 800, 1200, 1600, 2000]

    // MARK: - Titles

    static var gameTitle: String {
        String(localized: "defaults.game_title")
    }

    /// `round` is 1 or 2.
    static func roundTitle(round: Int) -> String {
        String(localized: "defaults.round_title \(round)")
    }

    /// `number` is the category's 1-based position in its round.
    static func categoryTitle(_ number: Int) -> String {
        String(localized: "defaults.category_title \(number)")
    }

    // MARK: - Clues

    static func clue(category number: Int, value: Int) -> String {
        String(localized: "defaults.clue \(number) \(String(value))")
    }

    static func answer(category number: Int, value: Int) -> String {
        String(localized: "defaults.answer \(number) \(String(value))")
    }

    // MARK: - Final round

    static var finalCategory: String {
        String(localized: "defaults.final.category")
    }

    static var finalClue: String {
        String(localized: "defaults.final.clue")
    }

    static var finalAnswer: String {
        String(localized: "defaults.final.answer")
    }

    // MARK: - Layout

    /// Daily Doubles a new board starts with, as (category, row) positions
    /// counted from 0. One in round 1 and two in round 2, in different categories.
    static func dailyDoublePositions(round: Int) -> [(category: Int, row: Int)] {
        round == 1 ? [(1, 2)] : [(1, 2), (4, 4)]
    }

    /// A round's categories filled with the defaults. `round` is 1 or 2.
    static func makeCategories(round: Int) -> [DraftCategory] {
        let values = round == 1 ? round1Values : round2Values
        let dailyDoubles = dailyDoublePositions(round: round)

        return (0..<BoardDraft.categoriesPerRound).map { categoryIndex in
            DraftCategory(
                title: categoryTitle(categoryIndex + 1),
                questions: values.enumerated().map { row, value in
                    DraftQuestion(
                        value: value,
                        clue: clue(category: categoryIndex + 1, value: value),
                        response: answer(category: categoryIndex + 1, value: value),
                        isDailyDouble: dailyDoubles.contains { $0.category == categoryIndex && $0.row == row }
                    )
                }
            )
        }
    }

    static func makeFinal() -> DraftFinalMacpardy {
        DraftFinalMacpardy(category: finalCategory, clue: finalClue, response: finalAnswer)
    }

    /// A complete new game.
    static func makeDraft() -> BoardDraft {
        BoardDraft(
            title: gameTitle,
            round1Title: roundTitle(round: 1),
            round1Categories: makeCategories(round: 1),
            round1Values: round1Values,
            round2Title: roundTitle(round: 2),
            round2Categories: makeCategories(round: 2),
            round2Values: round2Values,
            finalTitle: BoardDraft.defaultTitle(for: .finalMacpardy),
            finalMacpardy: makeFinal()
        )
    }
}
