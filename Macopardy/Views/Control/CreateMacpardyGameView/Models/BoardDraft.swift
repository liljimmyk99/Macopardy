//
//  BoardDraft.swift
//  Macopardy
//

import Foundation

/// Everything the game editor holds, separate from the view.
///
/// "Create game" starts from the editor's blank defaults; "Edit game" starts
/// from `init(boards:gameTitle:fallbackTitle:)`. `makeBoards()` turns a draft
/// back into the three boards the game plays.
struct BoardDraft: Equatable {

    /// The editor's grid: categories per round and clues per category.
    static let categoriesPerRound = 6
    static let cluesPerCategory = 5

    /// The board-title suffix older versions of the editor added to the game
    /// title (e.g. "Trivia Night - Macpardy"). Only used to recover a game
    /// title from files saved before games had their own.
    static let legacyMacpardySuffix = " - Macpardy"

    /// The game's name, saved in the file alongside the boards.
    var title: String

    var round1Title: String
    var round1Categories: [DraftCategory]
    /// Point value of each row in round 1, top to bottom.
    var round1Values: [Int]

    var round2Title: String
    var round2Categories: [DraftCategory]
    /// Point value of each row in round 2, top to bottom.
    var round2Values: [Int]

    var finalTitle: String
    var finalMacpardy: DraftFinalMacpardy

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Whether any clue has a picture to save. Decides between a `.json`
    /// board and a `.macpardy` package when exporting an edited game.
    var hasImages: Bool {
        (round1Categories + round2Categories).contains { category in
            category.questions.contains { $0.image?.data != nil }
        }
    }

    /// The title a round gets when the user leaves it blank.
    static func defaultTitle(for round: MacpardyRound) -> String {
        round.displayName
    }

    /// The game's three boards. Text is trimmed; blank round and category
    /// names get a default.
    func makeBoards() -> [MacpardyBoard] {
        let finalCategory = finalMacpardy.category.trimmingCharacters(in: .whitespacesAndNewlines)

        return [
            MacpardyBoard(
                title: Self.boardTitle(round1Title, round: .macpardy),
                round: .macpardy,
                categories: Self.makeCategories(from: round1Categories)
            ),
            MacpardyBoard(
                title: Self.boardTitle(round2Title, round: .doubleMacpardy),
                round: .doubleMacpardy,
                categories: Self.makeCategories(from: round2Categories)
            ),
            MacpardyBoard(
                title: Self.boardTitle(finalTitle, round: .finalMacpardy),
                round: .finalMacpardy,
                categories: [
                    Category(
                        title: finalCategory.isEmpty ? String(localized: "create.final_macpardy.default_category") : finalCategory,
                        questions: [
                            Question(
                                value: 0,
                                clue: finalMacpardy.clue.trimmingCharacters(in: .whitespacesAndNewlines),
                                response: finalMacpardy.response.trimmingCharacters(in: .whitespacesAndNewlines)
                            )
                        ]
                    )
                ]
            ),
        ]
    }

    private static func boardTitle(_ title: String, round: MacpardyRound) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultTitle(for: round) : trimmed
    }

    private static func makeCategories(from drafts: [DraftCategory]) -> [Category] {
        drafts.enumerated().map { index, category in
            let trimmedCategoryTitle = category.title.trimmingCharacters(in: .whitespacesAndNewlines)
            return Category(
                title: trimmedCategoryTitle.isEmpty ? String(localized: "create.category_default_name \(index + 1)") : trimmedCategoryTitle,
                questions: category.questions.map { question in
                    Question(
                        value: question.value,
                        clue: question.clue.trimmingCharacters(in: .whitespacesAndNewlines),
                        response: question.response.trimmingCharacters(in: .whitespacesAndNewlines),
                        isDailyDouble: question.isDailyDouble,
                        image: question.image
                    )
                }
            )
        }
    }
}

// MARK: - Loading existing boards

extension BoardDraft {

    /// Why a set of boards can't be shown in the editor. The editor has a
    /// fixed layout: one Macpardy round and one Double Macpardy round, each
    /// 6 categories × 5 clues where every category has the same point
    /// values, and one Final Macpardy clue.
    enum ShapeError: Error, Equatable {
        case missingRound(MacpardyRound)
        case duplicateRound(MacpardyRound)
        /// The round doesn't have `categoriesPerRound` categories.
        case wrongCategoryCount(round: MacpardyRound, found: Int)
        /// The category doesn't have `cluesPerCategory` clues.
        case wrongClueCount(round: MacpardyRound, category: String, found: Int)
        /// A category's values (sorted) differ from the round's first category.
        case mismatchedValues(round: MacpardyRound, category: String, expected: [Int], found: [Int])
        /// Final Macpardy must be exactly one category with one clue.
        case finalShape(categories: Int, questions: Int)
    }

    /// Builds a draft from a saved game so it can be edited.
    ///
    /// `gameTitle` is the title saved in the file. Files saved before games
    /// had their own title don't have one; the title is then the Macpardy
    /// board's title without the old " - Macpardy" suffix, or failing that
    /// `fallbackTitle` (the file name).
    ///
    /// - Throws: `ShapeError` if the boards don't fit the editor.
    init(boards: [MacpardyBoard], gameTitle: String?, fallbackTitle: String) throws {
        let single = try Self.board(for: .macpardy, in: boards)
        let double = try Self.board(for: .doubleMacpardy, in: boards)
        let final = try Self.board(for: .finalMacpardy, in: boards)

        let round1 = try Self.draftCategories(from: single)
        let round2 = try Self.draftCategories(from: double)

        guard final.categories.count == 1,
              let finalCategory = final.categories.first,
              finalCategory.questions.count == 1,
              let finalQuestion = finalCategory.questions.first else {
            throw ShapeError.finalShape(
                categories: final.categories.count,
                questions: final.categories.reduce(0) { $0 + $1.questions.count }
            )
        }

        let savedTitle = gameTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        self.init(
            title: savedTitle.isEmpty
                ? Self.gameTitle(fromBoardTitle: single.title, fallback: fallbackTitle)
                : savedTitle,
            round1Title: single.title,
            round1Categories: round1.categories,
            round1Values: round1.values,
            round2Title: double.title,
            round2Categories: round2.categories,
            round2Values: round2.values,
            finalTitle: final.title,
            finalMacpardy: DraftFinalMacpardy(
                category: finalCategory.title,
                clue: finalQuestion.clue,
                response: finalQuestion.response
            )
        )
    }

    /// Recovers a game title for a file that didn't save one.
    static func gameTitle(fromBoardTitle boardTitle: String, fallback: String) -> String {
        let trimmed = boardTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasSuffix(legacyMacpardySuffix) {
            let stripped = String(trimmed.dropLast(legacyMacpardySuffix.count))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !stripped.isEmpty { return stripped }
        }
        let trimmedFallback = fallback.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedFallback.isEmpty ? trimmed : trimmedFallback
    }

    private static func board(for round: MacpardyRound, in boards: [MacpardyBoard]) throws -> MacpardyBoard {
        let matches = boards.filter { $0.round == round }
        guard let board = matches.first else { throw ShapeError.missingRound(round) }
        guard matches.count == 1 else { throw ShapeError.duplicateRound(round) }
        return board
    }

    /// One editor column per category, rows ordered by value.
    private static func draftCategories(from board: MacpardyBoard) throws -> (categories: [DraftCategory], values: [Int]) {
        guard board.categories.count == categoriesPerRound else {
            throw ShapeError.wrongCategoryCount(round: board.round, found: board.categories.count)
        }

        var roundValues: [Int]?
        var drafts: [DraftCategory] = []

        for category in board.categories {
            guard category.questions.count == cluesPerCategory else {
                throw ShapeError.wrongClueCount(round: board.round, category: category.title, found: category.questions.count)
            }

            // Sort by value, keeping file order for equal values.
            let questions = category.questions.enumerated()
                .sorted { ($0.element.value, $0.offset) < ($1.element.value, $1.offset) }
                .map(\.element)
            let values = questions.map(\.value)

            if let roundValues, roundValues != values {
                throw ShapeError.mismatchedValues(
                    round: board.round,
                    category: category.title,
                    expected: roundValues,
                    found: values
                )
            }
            roundValues = roundValues ?? values

            drafts.append(DraftCategory(
                title: category.title,
                questions: questions.map { question in
                    DraftQuestion(
                        value: question.value,
                        clue: question.clue,
                        response: question.response,
                        isDailyDouble: question.isDailyDouble,
                        image: question.image
                    )
                }
            ))
        }

        return (drafts, roundValues ?? [])
    }
}
