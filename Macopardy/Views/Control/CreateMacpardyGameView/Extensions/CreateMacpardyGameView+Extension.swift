//
//  CreateMacpardyGameView+Extension.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import Foundation
import SwiftUI
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
            round1Title: round1Title,
            round1Categories: round1Categories,
            round1Values: round1BoardValues,
            round2Title: round2Title,
            round2Categories: round2Categories,
            round2Values: round2BoardValues,
            finalTitle: finalTitle,
            finalMacpardy: finalMacpardy
        )
    }

    /// Whether an edited board has changed since it was loaded or last saved.
    /// New games ("Create game") are never counted.
    var hasUnsavedEdits: Bool {
        guard isEditingExistingBoard, let savedDraft else { return false }
        return currentDraft != savedDraft
    }

    // MARK: - Round titles

    var currentRoundKind: MacpardyRound {
        switch currentRound {
        case 0: .macpardy
        case 1: .doubleMacpardy
        default: .finalMacpardy
        }
    }

    /// The title field for whichever round is showing.
    var currentRoundTitle: Binding<String> {
        switch currentRound {
        case 0: $round1Title
        case 1: $round2Title
        default: $finalTitle
        }
    }

    // MARK: - Saving

    func saveGame() {
        saveGame(thenFinish: nil)
    }

    /// Validates and opens the save panel. With a `request`, the close or
    /// quit it stands for goes ahead once the save succeeds, and is called
    /// off if the save doesn't happen.
    func saveGame(thenFinish request: BoardEditorSession.CloseRequest?) {
        let draft = currentDraft

        if draft.trimmedTitle.isEmpty {
            validationMessage = String(localized: "create.validation.missing_title")
            showValidationAlert = true
            if request != nil {
                finishClose(proceed: false)
            }
            return
        }

        closeAfterSave = request
        draftBeingSaved = draft
        // An edited board is saved as plain JSON unless it has pictures,
        // which need a package. New games are always saved as packages.
        exportContentType = isEditingExistingBoard && !draft.hasImages ? .json : .macpardyBoard
        exportDocument = FileManagerService().makeExportDocument(for: draft.makeBoards(), title: draft.trimmedTitle)
        showFileExporter = true
    }

    // MARK: - Closing with unsaved edits

    var unsavedPromptTitle: String {
        let name = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty
            ? String(localized: "edit.alert.unsaved.title_untitled")
            : String(localized: "edit.alert.unsaved.title \(name)")
    }

    /// Answers the pending close or quit. Going ahead throws away unsaved
    /// edits (they've either just been saved or the user chose not to).
    func finishClose(proceed: Bool) {
        let request = editorSession.closeRequest
        if proceed {
            savedDraft = currentDraft
            editorSession.hasUnsavedEdits = false
        }
        editorSession.finishClose(proceed: proceed)
        if proceed, request == .closeWindow {
            dismissWindow(id: "create-macpardy")
        }
    }

    /// Calls off a close or quit that was waiting on a save that didn't happen.
    func cancelPendingClose() {
        guard closeAfterSave != nil else { return }
        closeAfterSave = nil
        finishClose(proceed: false)
    }

    // MARK: - Loading

    /// Fills the editor with a board queued by "Edit game", if there is one.
    func loadPendingDraft() {
        guard let draft = editorSession.takePendingDraft() else { return }
        title = draft.title
        round1Title = draft.round1Title
        round1Categories = draft.round1Categories
        round1BoardValues = draft.round1Values
        round2Title = draft.round2Title
        round2Categories = draft.round2Categories
        round2BoardValues = draft.round2Values
        finalTitle = draft.finalTitle
        finalMacpardy = draft.finalMacpardy
        currentRound = 0
        selectedQuestion = nil
        exportDocument = nil
        savedDraft = draft
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

