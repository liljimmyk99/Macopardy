//
//  CreateMacpardyGameView+Extension.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import Foundation

extension CreateMacpardyGameView {
    func updateQuestion(categoryIndex: Int, questionIndex: Int, clue: String? = nil, response: String? = nil, isDailyDouble: Bool? = nil) {
        if currentRound == 0 {
            guard categoryIndex >= 0, categoryIndex < round1Categories.count else { return }
            guard questionIndex >= 0, questionIndex < round1Categories[categoryIndex].questions.count else { return }

            if let clue { round1Categories[categoryIndex].questions[questionIndex].clue = clue }
            if let response { round1Categories[categoryIndex].questions[questionIndex].response = response }
            if let isDailyDouble { round1Categories[categoryIndex].questions[questionIndex].isDailyDouble = isDailyDouble }
        } else if currentRound == 1 {
            guard categoryIndex >= 0, categoryIndex < round2Categories.count else { return }
            guard questionIndex >= 0, questionIndex < round2Categories[categoryIndex].questions.count else { return }

            if let clue { round2Categories[categoryIndex].questions[questionIndex].clue = clue }
            if let response { round2Categories[categoryIndex].questions[questionIndex].response = response }
            if let isDailyDouble { round2Categories[categoryIndex].questions[questionIndex].isDailyDouble = isDailyDouble }
        }
    }

    func saveGame() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.isEmpty {
            validationMessage = String(localized: "create.validation.missing_title")
            showValidationAlert = true
            return
        }

        let board1 = MacpardyBoard(
            title: "\(trimmedTitle) - Macpardy",
            round: .macpardy,
            categories: round1Categories.enumerated().map { index, category in
                let trimmedCategoryTitle = category.title.trimmingCharacters(in: .whitespacesAndNewlines)
                return Category(
                    title: trimmedCategoryTitle.isEmpty ? String(localized: "create.category_default_name \(index + 1)") : trimmedCategoryTitle,
                    questions: category.questions.map { question in
                        Question(
                            value: question.value,
                            clue: question.clue.trimmingCharacters(in: .whitespacesAndNewlines),
                            response: question.response.trimmingCharacters(in: .whitespacesAndNewlines),
                            isDailyDouble: question.isDailyDouble
                        )
                    }
                )
            }
        )

        let board2 = MacpardyBoard(
            title: "\(trimmedTitle) - Double Macpardy",
            round: .doubleMacpardy,
            categories: round2Categories.enumerated().map { index, category in
                let trimmedCategoryTitle = category.title.trimmingCharacters(in: .whitespacesAndNewlines)
                return Category(
                    title: trimmedCategoryTitle.isEmpty ? String(localized: "create.category_default_name \(index + 1)") : trimmedCategoryTitle,
                    questions: category.questions.map { question in
                        Question(
                            value: question.value,
                            clue: question.clue.trimmingCharacters(in: .whitespacesAndNewlines),
                            response: question.response.trimmingCharacters(in: .whitespacesAndNewlines),
                            isDailyDouble: question.isDailyDouble
                        )
                    }
                )
            }
        )

        let finalCategory = finalMacpardy.category.trimmingCharacters(in: .whitespacesAndNewlines)
        let board3 = MacpardyBoard(
            title: "\(trimmedTitle) - Final Macpardy",
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
        )

        exportDocument = FileManagerService().makeExportDocument(for: [board1, board2, board3])
        showFileExporter = true
    }

    static func makeDefaultCategories(values: [Int], titles: [String]) -> [DraftCategory] {
        titles.map { title in
            DraftCategory(
                title: title,
                questions: values.map { value in
                    DraftQuestion(value: value, clue: "", response: "")
                }
            )
        }
    }
}

