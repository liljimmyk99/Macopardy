//
//  LaunchScreenView.swift
//  Macopardy
//
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct LaunchScreenView: View {

    @Environment(\.openWindow) var openWindow
    @Environment(BoardEditorSession.self) var editorSession

    @Binding var hasSelectedGame: Bool
    @State var showFileExporter: Bool = false
    @Binding var gameState: GameState

    @State var showResumeAlert: Bool = false
    @State var pendingSavedSnapshot: GameSnapshot?
    @State var showNewGameSheet: Bool = false
    @State var showEditImporter: Bool = false
    @State var loadErrorReport: BoardLoadReport?
    /// The auto-saved game, if any, offered in the resume banner.
    @State var savedSnapshot: GameSnapshot?
    @State var showDiscardConfirmation: Bool = false

    var body: some View {
        VStack(spacing: 48) {
            launchTitle()
            actionTiles()

            if let savedSnapshot {
                ResumeGameBanner(
                    snapshot: savedSnapshot,
                    onResume: { resume(savedSnapshot) },
                    onDiscard: { showDiscardConfirmation = true }
                )
                .frame(maxWidth: 1020)
            }
        }
        .padding(48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MacpardyTheme.boardBlue)
        .preferredColorScheme(.dark)
        .task {
            savedSnapshot = await GameSaveStore.shared.load()
        }
        .fileImporter(
            isPresented: $showEditImporter,
            allowedContentTypes: [.macpardyBoard, .json, .zip, .commaSeparatedText]
        ) { result in
            handleEditPicked(result)
        }
        .sheet(item: $loadErrorReport) { report in
            BoardLoadErrorView(report: report)
        }
        .sheet(isPresented: $showNewGameSheet) {
            NewGameView(
                onBuildInEditor: {
                    showNewGameSheet = false
                    openWindow(id: "create-macpardy")
                },
                onPlay: { boards in
                    showNewGameSheet = false
                    gameState.loadGame(boards: boards)
                    hasSelectedGame = true
                }
            )
        }
        .alert("launch.alert.resume_title", isPresented: $showResumeAlert) {
            Button("launch.alert.resume_action") {
                if let snapshot = pendingSavedSnapshot {
                    resume(snapshot)
                }
            }
            Button("launch.alert.new_game_action", role: .destructive) {
                discardSavedGame()
                showFileExporter = true
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("launch.alert.resume_message")
        }
        .confirmationDialog("launch.resume.discard_confirm.title", isPresented: $showDiscardConfirmation) {
            Button("launch.resume.discard", role: .destructive) {
                discardSavedGame()
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("launch.resume.discard_confirm.message")
        }
        .fileImporter(
            isPresented: $showFileExporter,
            allowedContentTypes: [.macpardyBoard, .json],
            onCompletion: { result in
                switch result {
                case .success(let URL):
                    AppLogger.database.info("Successfully Imported \(URL.lastPathComponent)")
                    loadGame(url: URL)
                case .failure(let error):
                    AppLogger.database.error("\(error.localizedDescription)")
                }
            }
        )
    }
}

#Preview {
    LaunchScreenView(
        hasSelectedGame: .constant(false),
        gameState: .constant(GameState())
    )
    .environment(BoardEditorSession())
    .frame(width: 1200, height: 800)
}
