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
                    showFileExporter = true
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
    
    func loadGame(url: URL) {
        Task {
            do {
                let board = try await FileManagerService().readBoard(from: url)
                gameState.loadGame(board: board)
                hasSelectedGame = true
            } catch {
                AppLogger.control.error("Failed to decode board from JSON: \(error.localizedDescription)")
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
