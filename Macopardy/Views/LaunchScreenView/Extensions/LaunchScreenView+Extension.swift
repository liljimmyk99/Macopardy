//
//  LaunchScreenView+Extension.swift
//  Macopardy
//

import OSLog
import SwiftUI

extension LaunchScreenView {

    @ViewBuilder
    func launchTitle() -> some View {
        VStack(spacing: 12) {
            Text("launch.title")
                .font(MacpardyTheme.launchTitleFont)
                .foregroundStyle(MacpardyTheme.gold)
                .shadow(color: .black, radius: 0, x: 3, y: 3)
                .padding(.horizontal, 48)
                .padding(.vertical, 18)
                .background(MacpardyTheme.tileBlue)

            Text("launch.subtitle")
                .font(.title3)
                .foregroundStyle(MacpardyTheme.mutedText)
        }
    }

    @ViewBuilder
    func actionTiles() -> some View {
        HStack(alignment: .top, spacing: 6) {
            LaunchActionTile(
                title: "launch.tile.play",
                caption: "launch.tile.play.caption",
                systemImage: "play.fill",
                shortcut: "o"
            ) {
                handleOpenExistingGame()
            }

            LaunchActionTile(
                title: "launch.tile.new",
                caption: "launch.tile.new.caption",
                systemImage: "plus",
                shortcut: "n"
            ) {
                showNewGameSheet = true
            }

            LaunchActionTile(
                title: "launch.tile.edit",
                caption: "launch.tile.edit.caption",
                systemImage: "square.and.pencil",
                shortcut: "e"
            ) {
                showEditImporter = true
            }
        }
        // Sizes every tile to the tallest, so captions that wrap differently don't change them.
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: 1020)
    }

    /// Asks whether to resume first when an auto-save exists, since starting
    /// a new board replaces it.
    func handleOpenExistingGame() {
        Task {
            if let saved = await GameSaveStore.shared.load() {
                pendingSavedSnapshot = saved
                showResumeAlert = true
            } else {
                showFileExporter = true
            }
        }
    }

    func resume(_ snapshot: GameSnapshot) {
        gameState.restore(from: snapshot)
        hasSelectedGame = true
    }

    func discardSavedGame() {
        savedSnapshot = nil
        Task {
            await GameSaveStore.shared.clear()
        }
    }

    /// Loads a JSON, package, or CSV board and opens it in the editor.
    /// A bad file shows what's wrong and leaves the user here.
    func handleEditPicked(_ result: Result<URL, Error>) {
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
