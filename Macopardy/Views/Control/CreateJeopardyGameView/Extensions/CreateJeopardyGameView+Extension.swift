//
//  CreateJeopardyGameView+Extension.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import Foundation

extension CreateJeopardyGameView {
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

        let board1 = JeopardyBoard(
            title: "\(trimmedTitle) - Jeopardy",
            round: .jeopardy,
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

        let board2 = JeopardyBoard(
            title: "\(trimmedTitle) - Double Jeopardy",
            round: .doubleJeopardy,
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

        let finalCategory = finalJeopardy.category.trimmingCharacters(in: .whitespacesAndNewlines)
        let board3 = JeopardyBoard(
            title: "\(trimmedTitle) - Final Jeopardy",
            round: .finalJeopardy,
            categories: [
                Category(
                    title: finalCategory.isEmpty ? String(localized: "create.final_jeopardy.default_category") : finalCategory,
                    questions: [
                        Question(
                            value: 0,
                            clue: finalJeopardy.clue.trimmingCharacters(in: .whitespacesAndNewlines),
                            response: finalJeopardy.response.trimmingCharacters(in: .whitespacesAndNewlines)
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

