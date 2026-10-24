//
//  MacopardyApp.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import OSLog
import SwiftUI

@main
struct MacpardyApp: App {

    @State
    private var gameState = GameState()

    @State
    private var hasSelectedGame = false

    @State
    private var buzzerState = BuzzerState()

    @State
    private var editorSession = BoardEditorSession()

    private var buzzerTeams: [BuzzerTeam] {
        gameState.game.teams.map(BuzzerTeam.init(team:))
    }

    private var teamScores: [UUID: Int] {
        Dictionary(uniqueKeysWithValues: gameState.game.teams.map { ($0.id, $0.score) })
    }

    /// Buzzers arm on a normal question, are off (and can't be pressed) on a
    /// Daily Double, and are otherwise disabled.
    private var buzzerMode: BuzzerMode {
        switch gameState.phase {
        case .question where gameState.dailyDoubleTeamID == nil: .armed
        case .question, .dailyDouble: .unavailable
        default: .disabled
        }
    }

    /// Opens wagering on the phones while the Final category is shown, closes it otherwise.
    private func syncWagering() async {
        if gameState.phase == .finalMacpardyCategory {
            await buzzerState.openWagering(
                limits: gameState.finalWagerLimits,
                wagers: gameState.finalMacpardyWagers
            )
        } else {
            await buzzerState.closeWagering()
        }
    }

    /// Loads a board opened from Finder. Ignored while a game is in progress
    /// so an accidental double-click can't wipe it out.
    private func openBoard(at url: URL) {
        guard !hasSelectedGame else {
            AppLogger.control.info("Ignoring \(url.lastPathComponent, privacy: .public): a game is in progress")
            return
        }
        Task {
            do {
                let boards = try await FileManagerService().readBoards(from: url)
                gameState.loadGame(boards: boards)
                hasSelectedGame = true
            } catch {
                AppLogger.control.error("Failed to open board \(url.lastPathComponent, privacy: .public): \(error.localizedDescription)")
            }
        }
    }

    /// Starts a game the user just edited and saved. Ignored while a game is
    /// in progress, like boards opened from Finder.
    private func playEditedBoards(_ boards: [MacpardyBoard]) {
        guard !hasSelectedGame else {
            AppLogger.control.info("Ignoring edited board: a game is in progress")
            return
        }
        gameState.loadGame(boards: boards)
        hasSelectedGame = true
    }

    var body: some Scene {

        Window("Control", id: "control") {
            Group {
                if hasSelectedGame {
                    ControlView()
                        .environment(gameState)
                        .environment(buzzerState)
                } else {
                    LaunchScreenView(hasSelectedGame: $hasSelectedGame, gameState: $gameState)
                        .environment(buzzerState)
                        .environment(editorSession)
                }
            }
            // Double-clicking a .macpardy board in Finder opens it here.
            .onOpenURL { url in
                openBoard(at: url)
            }
        }
        .defaultSize(width: 1200, height: 900)
        .onChange(of: hasSelectedGame) { _, selected in
            if selected {
                Task {
                    await buzzerState.syncTeams(buzzerTeams)
                    await buzzerState.syncScores(teamScores)
                    await buzzerState.setMode(buzzerMode)
                    await syncWagering()
                    buzzerState.onWagerSubmitted = { submission in
                        gameState.setFinalWager(teamID: submission.teamID, amount: submission.amount)
                    }
                    await buzzerState.startServer()
                }
            } else {
                Task { await buzzerState.stopServer() }
            }
        }
        // Keyed on the phone-facing fields only, so score changes don't re-sync.
        .onChange(of: buzzerTeams) { _, teams in
            Task { await buzzerState.syncTeams(teams) }
        }
        .onChange(of: teamScores) { _, scores in
            Task {
                await buzzerState.syncScores(scores)
                // Max wagers follow scores while the Final category is up.
                if gameState.phase == .finalMacpardyCategory { await syncWagering() }
            }
        }
        // "Play now" after saving an edited board.
        .onChange(of: editorSession.boardsToPlay) { _, boards in
            guard let boards else { return }
            editorSession.boardsToPlay = nil
            playEditedBoards(boards)
        }
        .onChange(of: buzzerMode) { _, mode in
            Task { await buzzerState.setMode(mode) }
        }
        // Wagering is open exactly while the Final category is displayed.
        .onChange(of: gameState.phase) { _, _ in
            Task { await syncWagering() }
        }

        Window("Display", id: "display") {
            if hasSelectedGame {
                PresentationView()
                    .environment(gameState)
                    .environment(buzzerState)
            }
        }
        .defaultSize(width: 1920, height: 1080)
        .defaultLaunchBehavior(.suppressed)

        Window("Create Macpardy Game", id: "create-macpardy") {
            CreateMacpardyGameView()
                .environment(editorSession)
        }
        .defaultSize(width: 1400, height: 820)
        .defaultLaunchBehavior(.suppressed)
    }
}
