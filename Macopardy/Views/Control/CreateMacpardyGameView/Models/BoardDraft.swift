//
//  BoardDraft.swift
//  Macopardy
//

import Foundation

/// Everything the game editor holds, separate from the view.
///
/// "Create game" starts from the editor's blank defaults; "Edit game" starts
/// from `init(boards:fallbackTitle:)`. `makeBoards()` turns a draft back into
/// the three boards the game plays.
struct BoardDraft {

    /// Suffixes the editor appends to the game title for each board.
    static let macpardySuffix = " - Macpardy"
    static let doubleMacpardySuffix = " - Double Macpardy"
    static let finalMacpardySuffix = " - Final Macpardy"

    var title: String

    var round1Categories: [DraftCategory]
    /// Point value of each row in round 1, top to bottom.
    var round1Values: [Int]

    var round2Categories: [DraftCategory]
    /// Point value of each row in round 2, top to bottom.
    var round2Values: [Int]

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

    /// The game's three boards. Text is trimmed and blank category names get
    /// a default. Expects a non-empty title.
    func makeBoards() -> [MacpardyBoard] {
        let gameTitle = trimmedTitle
        let finalCategory = finalMacpardy.category.trimmingCharacters(in: .whitespacesAndNewlines)

        return [
            MacpardyBoard(
                title: gameTitle + Self.macpardySuffix,
                round: .macpardy,
                categories: Self.makeCategories(from: round1Categories)
            ),
            MacpardyBoard(
                title: gameTitle + Self.doubleMacpardySuffix,
                round: .doubleMacpardy,
                categories: Self.makeCategories(from: round2Categories)
            ),
            MacpardyBoard(
                title: gameTitle + Self.finalMacpardySuffix,
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
    /// fixed layout: one Macpardy round, one Double Macpardy round (each a
    /// grid where every category has the same point values), and one Final
    /// Macpardy clue.
    enum ShapeError: Error, Equatable {
        case missingRound(MacpardyRound)
        case duplicateRound(MacpardyRound)
        case emptyRound(MacpardyRound)
        case emptyCategory(round: MacpardyRound, category: String)
        /// A category's values (sorted) differ from the round's first category.
        case mismatchedValues(round: MacpardyRound, category: String, expected: [Int], found: [Int])
        /// Final Macpardy must be exactly one category with one clue.
        case finalShape(categories: Int, questions: Int)
    }

    /// Builds a draft from a saved game so it can be edited.
    ///
    /// The game title comes from the Macpardy board's title with the
    /// editor's " - Macpardy" suffix removed. Boards saved some other way
    /// don't have it, so `fallbackTitle` (the file name) is used instead.
    ///
    /// - Throws: `ShapeError` if the boards don't fit the editor.
    init(boards: [MacpardyBoard], fallbackTitle: String) throws {
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

        self.init(
            title: Self.gameTitle(fromBoardTitle: single.title, fallback: fallbackTitle),
            round1Categories: round1.categories,
            round1Values: round1.values,
            round2Categories: round2.categories,
            round2Values: round2.values,
            finalMacpardy: DraftFinalMacpardy(
                category: finalCategory.title,
                clue: finalQuestion.clue,
                response: finalQuestion.response
            )
        )
    }

    static func gameTitle(fromBoardTitle boardTitle: String, fallback: String) -> String {
        let trimmed = boardTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasSuffix(macpardySuffix) {
            let stripped = String(trimmed.dropLast(macpardySuffix.count))
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
        guard !board.categories.isEmpty else { throw ShapeError.emptyRound(board.round) }

        var roundValues: [Int]?
        var drafts: [DraftCategory] = []

        for category in board.categories {
            guard !category.questions.isEmpty else {
                throw ShapeError.emptyCategory(round: board.round, category: category.title)
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
