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
