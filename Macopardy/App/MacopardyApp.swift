//
//  MacopardyApp.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

@main
struct JeopardyApp: App {

    @State
    private var gameState = GameState()
    
    @State
    private var hasSelectedGame = false

    var body: some Scene {

        Window("Control", id: "control") {
            if hasSelectedGame {
                ControlView()
                    .environment(gameState)
            } else {
                LaunchScreenView(hasSelectedGame: $hasSelectedGame, gameState: gameState)
            }
        }
        .defaultSize(width: 1200, height: 900)

        Window("Display", id: "display") {
            if hasSelectedGame {
                PresentationView()
                    .environment(gameState)
            }
        }
        .defaultSize(width: 1920, height: 1080)
    }
}
