//
//  LaunchScreenView.swift
//  Macopardy
//
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct LaunchScreenView: View {

    @Environment(\.openWindow) private var openWindow
    @Environment(BoardEditorSession.self) private var editorSession

    @Binding var hasSelectedGame: Bool
    @State var showFileExporter: Bool = false
    @Binding var gameState: GameState

    @State private var showResumeAlert: Bool = false
    @State private var pendingSavedSnapshot: GameSnapshot?
    @State private var showNewGameSheet: Bool = false
    @State private var showEditImporter: Bool = false
    @State private var loadErrorReport: BoardLoadReport?

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                GameTitleView(title: "Macpardy!")
                Text("launch.welcome_title")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)

            VStack(spacing: 16) {
                LargeButton(
                    title: "launch.button.open_existing",
                    systemImage: "folder.open"
                ) {
                    handleOpenExistingGame()
                }

                LargeButton(
                    title: "launch.button.edit_existing",
                    systemImage: "square.and.pencil",
                    tint: .purple
                ) {
                    showEditImporter = true
                }
                .fileImporter(
                    isPresented: $showEditImporter,
                    allowedContentTypes: [.macpardyBoard, .json, .zip, .commaSeparatedText]
                ) { result in
                    handleEditPicked(result)
                }

                LargeButton(
                    title: "launch.button.new_game",
                    systemImage: "plus.circle",
                    tint: .orange
                ) {
                    showNewGameSheet = true
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.controlBackgroundColor))
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
                    gameState.restore(from: snapshot)
                    hasSelectedGame = true
                }
            }
            Button("launch.alert.new_game_action", role: .destructive) {
                Task {
                    await GameSaveStore.shared.clear()
                }
                showFileExporter = true
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("launch.alert.resume_message")
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

    private func handleOpenExistingGame() {
        Task {
            if let saved = await GameSaveStore.shared.load() {
                pendingSavedSnapshot = saved
                showResumeAlert = true
            } else {
                showFileExporter = true
            }
        }
    }
    
    /// Loads a JSON, package, or CSV board and opens it in the editor.
    /// A bad file shows what's wrong and leaves the user here.
    private func handleEditPicked(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let data = try FileManagerService().readData(from: url)
                let draft = try BoardLoader.load(data: data, fileName: url.lastPathComponent)
                AppLogger.database.info("Opened \(url.lastPathComponent, privacy: .public) for editing")
                editorSession.edit(draft)
                openWindow(id: "create-macpardy")
            } catch {
                AppLogger.database.error("Can't edit \(url.lastPathComponent, privacy: .public): \(String(describing: error), privacy: .public)")
                loadErrorReport = BoardLoadReport(fileName: url.lastPathComponent, error: error)
            }
        case .failure(let error):
            AppLogger.database.error("Edit picker failed: \(error.localizedDescription)")
        }
    }

    func loadGame(url: URL) {
        Task {
            do {
                let boards = try await FileManagerService().readBoards(from: url)
                gameState.loadGame(boards: boards)
                hasSelectedGame = true
            } catch {
                AppLogger.control.error("Failed to decode boards from JSON: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    LaunchScreenView(
        hasSelectedGame: .constant(false),
        gameState: .constant(GameState())
    )
    .environment(BoardEditorSession())
}
