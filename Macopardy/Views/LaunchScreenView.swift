//
//  LaunchScreenView.swift
//  Macopardy
//
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct LaunchScreenView: View {

    @Environment(\.openWindow) private var openWindow

    @Binding var hasSelectedGame: Bool
    @State var showFileExporter: Bool = false
    @Binding var gameState: GameState

    @State private var showResumeAlert: Bool = false
    @State private var pendingSavedSnapshot: GameSnapshot?

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
                    title: "launch.button.new_game",
                    systemImage: "plus.circle",
                    tint: .orange
                ) {
                    openWindow(id: "create-macpardy")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.controlBackgroundColor))
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
}
