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

    internal static let values = [200, 400, 600, 800, 1000]

    @State
    internal var title: String = ""

    @State
    internal var draftCategories: [DraftCategory] = Self.makeDefaultCategories()

    @State
    internal var selectedQuestion: EditingQuestion?

    @State
    internal var validationMessage: String = ""

    @State
    internal var showValidationAlert = false

    @State
    internal var saveErrorMessage: String = ""

    @State
    internal var showSaveErrorAlert = false

    @State
    internal var exportDocument: JeopardyBoardDocument?

    @State
    internal var showFileExporter = false
    
    @State
    internal var currentRound: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            GameTitleEditor(title: $title)
            
            RoundIndictator(currentRound: $currentRound)
            
            DraftBoard(
                draftCategories: $draftCategories,
                selectedQuestion: $selectedQuestion
            )


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
            defaultFilename: exportDocument.map {
                FileManagerService().defaultFilename(for: $0.board.title)
            }
        ) { result in
            switch result {
            case .success:
                AppLogger.database.info("Successfully Saved Board")
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
                    get: { draftCategories[question.categoryIndex].questions[question.questionIndex].clue },
                    set: { newValue in
                        updateQuestion(
                            categoryIndex: question.categoryIndex,
                            questionIndex: question.questionIndex,
                            clue: newValue
                        )
                    }
                ),
                response: Binding(
                    get: { draftCategories[question.categoryIndex].questions[question.questionIndex].response },
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
