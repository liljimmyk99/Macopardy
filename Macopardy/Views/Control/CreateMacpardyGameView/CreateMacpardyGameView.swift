//
//  CreateMacpardyGameView.swift
//  Macopardy
//

import SwiftUI
import UniformTypeIdentifiers
internal import os
//TODO: Change this to be creating a Game instead
struct CreateMacpardyGameView: View {
    @Environment(\.dismissWindow) internal var dismissWindow
    @Environment(\.openWindow) private var openWindow
    @Environment(BoardEditorSession.self) internal var editorSession

    internal static let round1DefaultCategories = [
        "Science",
        "History",
        "Literature",
        "Geography",
        "Pop Culture",
        "Think Music"
    ]

    internal static let round2DefaultCategories = [
        "World History",
        "Physical Science",
        "Fine Arts",
        "World Geography",
        "Music & Movies",
        "Word Play"
    ]

    internal static let round1Values = [200, 400, 600, 800, 1000]
    internal static let round2Values = [400, 800, 1200, 1600, 2000]

    @State internal var title: String = ""
    @State internal var currentRound: Int = 0

    @State internal var round1Categories: [DraftCategory] = Self.makeDefaultCategories(values: Self.round1Values, titles: Self.round1DefaultCategories)
    @State internal var round2Categories: [DraftCategory] = Self.makeDefaultCategories(values: Self.round2Values, titles: Self.round2DefaultCategories)
    @State internal var finalMacpardy: DraftFinalMacpardy = DraftFinalMacpardy()

    /// Each round's own title, shown on the control screen during play.
    @State internal var round1Title: String = BoardDraft.defaultTitle(for: .macpardy)
    @State internal var round2Title: String = BoardDraft.defaultTitle(for: .doubleMacpardy)
    @State internal var finalTitle: String = BoardDraft.defaultTitle(for: .finalMacpardy)

    /// Row values for each round. The defaults for a new game; a loaded
    /// board keeps its own.
    @State internal var round1BoardValues: [Int] = Self.round1Values
    @State internal var round2BoardValues: [Int] = Self.round2Values

    /// `true` once a loaded board is in the editor ("Edit game").
    @State internal var isEditingExistingBoard = false

    /// The edited board as last loaded or saved; unsaved edits are any
    /// difference from it.
    @State internal var savedDraft: BoardDraft?

    /// The draft handed to the save panel, which becomes `savedDraft` once
    /// the save succeeds.
    @State internal var draftBeingSaved: BoardDraft?

    /// Close or quit to finish once the current save succeeds.
    @State internal var closeAfterSave: BoardEditorSession.CloseRequest?

    @State internal var showUnsavedPrompt = false

    @State internal var selectedQuestion: EditingQuestion?

    @State internal var validationMessage: String = ""
    @State internal var showValidationAlert = false

    @State internal var saveErrorMessage: String = ""
    @State internal var showSaveErrorAlert = false

    @State internal var exportDocument: MacpardyBoardsDocument?
    @State internal var exportContentType: UTType = .macpardyBoard
    @State internal var showFileExporter = false

    @State internal var showPlayPrompt = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            GameTitleEditor(title: $title)
            
            RoundIndictator(currentRound: $currentRound)

            RoundTitleEditor(title: currentRoundTitle, round: currentRoundKind)

            if currentRound == 0 {
                DraftBoard(
                    draftCategories: $round1Categories,
                    selectedQuestion: $selectedQuestion,
                    values: round1BoardValues
                )
            } else if currentRound == 1 {
                DraftBoard(
                    draftCategories: $round2Categories,
                    selectedQuestion: $selectedQuestion,
                    values: round2BoardValues
                )
            } else {
                DraftFinalMacpardyView(draft: $finalMacpardy)
            }

            DraftBoardControls(
                currentRound: $currentRound,
                saveGame: { saveGame() }
            )
        }
        .padding(20)
        .frame(minWidth: 1200, minHeight: 820)
        .background(MacpardyTheme.controlBackground)
        .alert("create.alert.incomplete_title", isPresented: $showValidationAlert) {
            Button("common.ok") {}
        } message: {
            Text(validationMessage)
        }
        .alert("create.alert.save_failed_title", isPresented: $showSaveErrorAlert) {
            Button("common.ok") {}
        } message: {
            Text(saveErrorMessage)
        }
        .alert(unsavedPromptTitle, isPresented: $showUnsavedPrompt) {
            Button("edit.alert.unsaved.save") {
                saveGame(thenFinish: editorSession.closeRequest)
            }
            Button("edit.alert.unsaved.discard", role: .destructive) {
                finishClose(proceed: true)
            }
            Button("common.cancel", role: .cancel) {
                finishClose(proceed: false)
            }
        } message: {
            Text("edit.alert.unsaved.message")
        }
        .alert("edit.alert.play_title", isPresented: $showPlayPrompt) {
            Button("edit.alert.play_action") {
                if let boards = exportDocument?.boards {
                    editorSession.boardsToPlay = boards
                }
                openWindow(id: "control")
                dismissWindow(id: "create-macpardy")
            }
            Button("edit.alert.not_now_action", role: .cancel) {
                dismissWindow(id: "create-macpardy")
            }
        } message: {
            Text("edit.alert.play_message")
        }
        .fileExporter(
            isPresented: $showFileExporter,
            document: exportDocument,
            contentType: exportContentType,
            defaultFilename: exportDocument.map { _ in
                exportContentType == .json
                    ? FileManagerService().defaultJSONFilename(for: title)
                    : FileManagerService().defaultFilename(for: title)
            }
        ) { result in
            switch result {
            case .success(let url):
                AppLogger.database.info("Saved boards to \(url.lastPathComponent, privacy: .public)")
                savedDraft = draftBeingSaved
                if closeAfterSave != nil {
                    // Saved from the "save changes?" prompt: carry on closing.
                    closeAfterSave = nil
                    finishClose(proceed: true)
                } else if isEditingExistingBoard {
                    showPlayPrompt = true
                } else {
                    dismissWindow(id: "create-macpardy")
                }
            case .failure(let error):
                if (error as? CocoaError)?.code != .userCancelled {
                    saveErrorMessage = String(localized: "create.alert.save_error_message \(error.localizedDescription)")
                    showSaveErrorAlert = true
                }
                AppLogger.database.error("\(error.localizedDescription)")
                cancelPendingClose()
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
                isDailyDouble: Binding(
                    get: {
                        if currentRound == 0 {
                            return round1Categories[question.categoryIndex].questions[question.questionIndex].isDailyDouble
                        } else {
                            return round2Categories[question.categoryIndex].questions[question.questionIndex].isDailyDouble
                        }
                    },
                    set: { newValue in
                        updateQuestion(
                            categoryIndex: question.categoryIndex,
                            questionIndex: question.questionIndex,
                            isDailyDouble: newValue
                        )
                    }
                ),
                image: Binding(
                    get: {
                        if currentRound == 0 {
                            return round1Categories[question.categoryIndex].questions[question.questionIndex].image
                        } else {
                            return round2Categories[question.categoryIndex].questions[question.questionIndex].image
                        }
                    },
                    set: { newValue in
                        updateImage(
                            categoryIndex: question.categoryIndex,
                            questionIndex: question.questionIndex,
                            image: newValue
                        )
                    }
                ),
                onDone: {
                    selectedQuestion = nil
                }
            )
            .frame(minWidth: 540, minHeight: 520)
        }
        // "Edit game" queues a loaded board; pick it up when the window opens,
        // or right away if it's already open.
        .onAppear {
            loadPendingDraft()
        }
        .onChange(of: editorSession.editRequest) { _, _ in
            loadPendingDraft()
        }
        // Unsaved edits block closing the window or quitting until the user answers.
        .onChange(of: hasUnsavedEdits, initial: true) { _, unsaved in
            editorSession.hasUnsavedEdits = unsaved
        }
        .onChange(of: editorSession.closeRequest) { _, request in
            if request != nil {
                showUnsavedPrompt = true
            }
        }
        .onDisappear {
            editorSession.hasUnsavedEdits = false
        }
        .background(
            WindowCloseGuard(
                shouldClose: { [editorSession] in
                    guard editorSession.hasUnsavedEdits else { return true }
                    editorSession.requestClose(.closeWindow)
                    return false
                },
                onWindow: { [editorSession] window in
                    editorSession.editorWindow = window
                }
            )
        )
    }
}

#Preview {
    CreateMacpardyGameView()
        .environment(BoardEditorSession())
}
