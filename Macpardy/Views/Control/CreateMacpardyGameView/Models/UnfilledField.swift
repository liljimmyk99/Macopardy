//
//  UnfilledField.swift
//  Macpardy
//

import Foundation

/// A field in the editor that is empty or still holds its default text.
struct UnfilledField: Equatable, Identifiable {

    enum Kind: Equatable {
        case gameTitle
        case roundTitle
        case category
        case clue
        case answer
        case finalCategory
        case finalClue
        case finalAnswer
    }

    let kind: Kind
    /// 0 and 1 for the two board rounds, 2 for Final. `nil` for the game title.
    let round: Int?
    /// 0-based column, for category, clue, and answer fields.
    let category: Int?
    /// 0-based row, for clue and answer fields.
    let row: Int?
    /// Point value, for clue and answer fields.
    let value: Int?

    var id: String {
        "\(kind)-\(round ?? -1)-\(category ?? -1)-\(row ?? -1)"
    }

    /// Where the field is, e.g. "Round 1, category 2, $400 clue".
    var location: String {
        let round = (round ?? 0) + 1
        let category = (category ?? 0) + 1
        let value = value ?? 0
        switch kind {
        case .gameTitle:
            return String(localized: "create.unfilled.location.game_title")
        case .roundTitle:
            return String(localized: "create.unfilled.location.round_title \(round)")
        case .category:
            return String(localized: "create.unfilled.location.category \(round) \(category)")
        case .clue:
            return String(localized: "create.unfilled.location.clue \(round) \(category) \(String(value))")
        case .answer:
            return String(localized: "create.unfilled.location.answer \(round) \(category) \(String(value))")
        case .finalCategory:
            return String(localized: "create.unfilled.location.final_category")
        case .finalClue:
            return String(localized: "create.unfilled.location.final_clue")
        case .finalAnswer:
            return String(localized: "create.unfilled.location.final_answer")
        }
    }

    /// The part of the game the field is in, used to group the warning:
    /// the game, a round's title, one category, or Final.
    var area: String {
        let round = (round ?? 0) + 1
        switch kind {
        case .gameTitle:
            return String(localized: "create.unfilled.area.game")
        case .roundTitle:
            return String(localized: "create.unfilled.area.round \(round)")
        case .category, .clue, .answer:
            return String(localized: "create.unfilled.area.category \(round) \((category ?? 0) + 1)")
        case .finalCategory, .finalClue, .finalAnswer:
            return String(localized: "create.unfilled.area.final")
        }
    }
}

extension Array where Element == UnfilledField {

    func contains(_ kind: UnfilledField.Kind, round: Int? = nil, category: Int? = nil, row: Int? = nil) -> Bool {
        contains { $0.kind == kind && $0.round == round && $0.category == category && $0.row == row }
    }

    /// Fields in a round (0, 1, or 2 for Final), not counting the game title.
    func fieldCount(inRound round: Int) -> Int {
        filter { $0.round == round }.count
    }

    /// The area names in order of first appearance, each with its field count.
    var groupedByArea: [(area: String, count: Int)] {
        var groups: [(area: String, count: Int)] = []
        for field in self {
            let area = field.area
            if let index = groups.firstIndex(where: { $0.area == area }) {
                groups[index].count += 1
            } else {
                groups.append((area, 1))
            }
        }
        return groups
    }
}

extension BoardDraft {

    /// Fields that are empty or still hold their default text (compared
    /// after trimming), in the order they appear in the editor.
    func unfilledFields() -> [UnfilledField] {
        var fields: [UnfilledField] = []

        if isUnfilled(title, default: BoardDefaults.gameTitle) {
            fields.append(UnfilledField(kind: .gameTitle, round: nil, category: nil, row: nil, value: nil))
        }

        let rounds = [
            (round1Title, round1Categories),
            (round2Title, round2Categories),
        ]
        for (round, content) in rounds.enumerated() {
            let (roundTitle, categories) = content
            if isUnfilled(roundTitle, default: BoardDefaults.roundTitle(round: round + 1)) {
                fields.append(UnfilledField(kind: .roundTitle, round: round, category: nil, row: nil, value: nil))
            }
            for (categoryIndex, category) in categories.enumerated() {
                if isUnfilled(category.title, default: BoardDefaults.categoryTitle(categoryIndex + 1)) {
                    fields.append(UnfilledField(kind: .category, round: round, category: categoryIndex, row: nil, value: nil))
                }
                for (row, question) in category.questions.enumerated() {
                    if isUnfilled(question.clue, default: BoardDefaults.clue(category: categoryIndex + 1, value: question.value)) {
                        fields.append(UnfilledField(kind: .clue, round: round, category: categoryIndex, row: row, value: question.value))
                    }
                    if isUnfilled(question.response, default: BoardDefaults.answer(category: categoryIndex + 1, value: question.value)) {
                        fields.append(UnfilledField(kind: .answer, round: round, category: categoryIndex, row: row, value: question.value))
                    }
                }
            }
        }

        if isUnfilled(finalMacpardy.category, default: BoardDefaults.finalCategory) {
            fields.append(UnfilledField(kind: .finalCategory, round: 2, category: nil, row: nil, value: nil))
        }
        if isUnfilled(finalMacpardy.clue, default: BoardDefaults.finalClue) {
            fields.append(UnfilledField(kind: .finalClue, round: 2, category: nil, row: nil, value: nil))
        }
        if isUnfilled(finalMacpardy.response, default: BoardDefaults.finalAnswer) {
            fields.append(UnfilledField(kind: .finalAnswer, round: 2, category: nil, row: nil, value: nil))
        }

        return fields
    }

    private func isUnfilled(_ text: String, default defaultText: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty || trimmed == defaultText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
