//
//  CreateJeopardyGameView.swift
//  Macopardy
//

import SwiftUI
import UniformTypeIdentifiers
internal import os
//TODO: Change this to be creating a Game instead
struct CreateJeopardyGameView: View {
    @Environment(\.dismissWindow) private var dismissWindow

    internal static let categoryTitles = [
        "Science",
        "History",
        "Literature",
        "Geography",
        "Pop Culture",
        "Think Music"
    ]

    internal static let round1Values = [200, 400, 600, 800, 1000]
    internal static let round2Values = [400, 800, 1200, 1600, 2000]

    @State internal var title: String = ""
    @State internal var currentRound: Int = 0

    @State internal var round1Categories: [DraftCategory] = Self.makeDefaultCategories(values: round1Values)
    @State internal var round2Categories: [DraftCategory] = Self.makeDefaultCategories(values: round2Values)
    @State internal var finalJeopardy: DraftFinalJeopardy = DraftFinalJeopardy()

    @State internal var selectedQuestion: EditingQuestion?

    @State internal var validationMessage: String = ""
    @State internal var showValidationAlert = false

    @State internal var saveErrorMessage: String = ""
    @State internal var showSaveErrorAlert = false

    @State internal var exportDocument: JeopardyBoardsDocument?
    @State internal var showFileExporter = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            GameTitleEditor(title: $title)
            
            RoundIndictator(currentRound: $currentRound)
            
            if currentRound == 0 {
                DraftBoard(
                    draftCategories: $round1Categories,
                    selectedQuestion: $selectedQuestion,
                    values: Self.round1Values
                )
            } else if currentRound == 1 {
                DraftBoard(
                    draftCategories: $round2Categories,
                    selectedQuestion: $selectedQuestion,
                    values: Self.round2Values
                )
            } else {
                DraftFinalJeopardyView(draft: $finalJeopardy)
            }

            DraftBoardControls(
                currentRound: $currentRound,
                saveGame: saveGame
            )
        }
        .padding(20)
        .frame(minWidth: 1200, minHeight: 820)
        .background(JeopardyTheme.controlBackground)
        .alert("Game incomplete", isPresented: $showValidationAlert) {
            Button("OK") {}
        } message: {
            Text(validationMessage)
        }
        .alert("Save failed", isPresented: $showSaveErrorAlert) {
            Button("OK") {}
        } message: {
            Text(saveErrorMessage)
        }
        .fileExporter(
            isPresented: $showFileExporter,
            document: exportDocument,
            contentType: .json,
            defaultFilename: exportDocument.map { _ in
                FileManagerService().defaultFilename(for: title)
            }
        ) { result in
            switch result {
            case .success:
                AppLogger.database.info("Successfully Saved Boards")
                dismissWindow(id: "create-jeopardy")
            case .failure(let error):
                if (error as? CocoaError)?.code != .userCancelled {
                    saveErrorMessage = "The game could not be saved.\n\(error.localizedDescription)"
                    showSaveErrorAlert = true
                }
                AppLogger.database.error("\(error.localizedDescription)")
            }
        }
        .sheet(item: $selectedQuestion) { question in
            QuestionEditorView(
                value: question.value,
                clue: Binding(
                    get: {
                        if currentRound == 0 {
                            return round1Categories[question.categoryIndex].questions[question.questionIndex].clue
                        } else {
                            return round2Categories[question.categoryIndex].questions[question.questionIndex].clue
                        }
                    },
                    set: { newValue in
                        updateQuestion(
                            categoryIndex: question.categoryIndex,
                            questionIndex: question.questionIndex,
                            clue: newValue
                        )
                    }
                ),
                response: Binding(
                    get: {
                        if currentRound == 0 {
                            return round1Categories[question.categoryIndex].questions[question.questionIndex].response
                        } else {
                            return round2Categories[question.categoryIndex].questions[question.questionIndex].response
                        }
                    },
                    set: { newValue in
                        updateQuestion(
                            categoryIndex: question.categoryIndex,
                            questionIndex: question.questionIndex,
                            response: newValue
                        )
                    }
                ),
                onDone: {
                    selectedQuestion = nil
                }
            )
            .frame(minWidth: 540, minHeight: 360)
        }
    }
}

#Preview {
    CreateJeopardyGameView()
}
