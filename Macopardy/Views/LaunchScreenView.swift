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
                GameTitleView(title: "Jeopardy!")
                Text("Welcome to Macopardy")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)

            VStack(spacing: 16) {
                LargeButton(
                    title: "Open Existing Game",
                    systemImage: "folder.open"
                ) {
                    handleOpenExistingGame()
                }

                LargeButton(
                    title: "New Game",
                    systemImage: "plus.circle",
                    tint: .orange
                ) {
                    openWindow(id: "create-jeopardy")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.controlBackgroundColor))
        .alert("Resume previous game?", isPresented: $showResumeAlert) {
            Button("Resume") {
                if let snapshot = pendingSavedSnapshot {
                    gameState.restore(from: snapshot)
                    hasSelectedGame = true
                }
            }
            Button("New Game", role: .destructive) {
                Task {
                    await GameSaveStore.shared.clear()
                }
                showFileExporter = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("A previously active game was found. Would you like to resume where you left off or start a new game?")
        }
        .fileImporter(
            isPresented: $showFileExporter,
            allowedContentTypes: [.json],
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
