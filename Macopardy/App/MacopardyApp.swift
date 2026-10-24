//
//  MacopardyApp.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

@main
struct MacpardyApp: App {

    @State
    private var gameState = GameState()

    @State
    private var hasSelectedGame = false

    @State
    private var buzzerState = BuzzerState()

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

    var body: some Scene {

        Window("Control", id: "control") {
            if hasSelectedGame {
                ControlView()
                    .environment(gameState)
                    .environment(buzzerState)
            } else {
                LaunchScreenView(hasSelectedGame: $hasSelectedGame, gameState: $gameState)
                    .environment(buzzerState)
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
        }
        .defaultSize(width: 1400, height: 820)
        .defaultLaunchBehavior(.suppressed)
    }
}
