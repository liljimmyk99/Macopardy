//
//  CreateJeopardyGameView+Extension.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import Foundation

extension CreateJeopardyGameView {
    func updateQuestion(categoryIndex: Int, questionIndex: Int, clue: String? = nil, response: String? = nil) {
        guard categoryIndex >= 0, categoryIndex < draftCategories.count else { return }
        guard questionIndex >= 0, questionIndex < draftCategories[categoryIndex].questions.count else { return }

        draftCategories[categoryIndex].questions[questionIndex].clue = clue ?? draftCategories[categoryIndex].questions[questionIndex].clue
        draftCategories[categoryIndex].questions[questionIndex].response = response ?? draftCategories[categoryIndex].questions[questionIndex].response
    }

    func saveGame() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.isEmpty {
            validationMessage = "Your game is incomplete. Please enter a game title before saving."
            showValidationAlert = true
            return
        }
        //TODO: Uncomment after create game logic is complete
        /*
        let incompleteQuestions = missingQuestions()
        if !incompleteQuestions.isEmpty {
            validationMessage = "Your game is incomplete. Please complete all categories and questions before saving. Missing: \(incompleteQuestions.joined(separator: ", "))"
            showValidationAlert = true
            return
        }
         */

        let board = JeopardyBoard(
            title: trimmedTitle,
            round: .jeopardy,
            categories: draftCategories.map { category in
                Category(
                    title: category.title,
                    questions: category.questions.map { question in
                        Question(
                            value: question.value,
                            clue: question.clue.trimmingCharacters(in: .whitespacesAndNewlines),
                            response: question.response.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                    }
                )
            }
        )

        exportDocument = FileManagerService().makeExportDocument(for: board)
        showFileExporter = true
    }

    func missingQuestions() -> [String] {
        var missing: [String] = []

        for category in draftCategories {
            for question in category.questions {
                let clueIsEmpty = question.clue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                let responseIsEmpty = question.response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                if clueIsEmpty || responseIsEmpty {
                    missing.append("\(category.title) - \(question.value)")
                }
            }
        }

        return missing
    }
    

    static func makeDefaultCategories() -> [DraftCategory] {
        categoryTitles.map { title in
            DraftCategory(
                title: title,
                questions: values.map { value in
                    DraftQuestion(value: value, clue: "", response: "")
                }
            )
        }
    }
}
