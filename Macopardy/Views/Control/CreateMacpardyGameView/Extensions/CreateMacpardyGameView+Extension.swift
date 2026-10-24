//
//  CreateMacpardyGameView+Extension.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import Foundation
import UniformTypeIdentifiers

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

    /// Sets or clears (`nil`) the image on a question in the current round.
    func updateImage(categoryIndex: Int, questionIndex: Int, image: QuestionImage?) {
        if currentRound == 0 {
            guard round1Categories.indices.contains(categoryIndex),
                  round1Categories[categoryIndex].questions.indices.contains(questionIndex) else { return }
            round1Categories[categoryIndex].questions[questionIndex].image = image
        } else if currentRound == 1 {
            guard round2Categories.indices.contains(categoryIndex),
                  round2Categories[categoryIndex].questions.indices.contains(questionIndex) else { return }
            round2Categories[categoryIndex].questions[questionIndex].image = image
        }
    }

    /// The editor's current contents.
    var currentDraft: BoardDraft {
        BoardDraft(
            title: title,
            round1Categories: round1Categories,
            round1Values: round1BoardValues,
            round2Categories: round2Categories,
            round2Values: round2BoardValues,
            finalMacpardy: finalMacpardy
        )
    }

    func saveGame() {
        let draft = currentDraft

        if draft.trimmedTitle.isEmpty {
            validationMessage = String(localized: "create.validation.missing_title")
            showValidationAlert = true
            return
        }

        // An edited board is saved as plain JSON unless it has pictures,
        // which need a package. New games are always saved as packages.
        exportContentType = isEditingExistingBoard && !draft.hasImages ? .json : .macpardyBoard
        exportDocument = FileManagerService().makeExportDocument(for: draft.makeBoards())
        showFileExporter = true
    }

    /// Fills the editor with a board queued by "Edit game", if there is one.
    func loadPendingDraft() {
        guard let draft = editorSession.takePendingDraft() else { return }
        title = draft.title
        round1Categories = draft.round1Categories
        round1BoardValues = draft.round1Values
        round2Categories = draft.round2Categories
        round2BoardValues = draft.round2Values
        finalMacpardy = draft.finalMacpardy
        currentRound = 0
        selectedQuestion = nil
        exportDocument = nil
        isEditingExistingBoard = true
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

