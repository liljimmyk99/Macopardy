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

    var body: some Scene {

        Window("Control", id: "control") {
            ControlPanelView()
                .environment(gameState)
        }
        .defaultSize(width: 1200, height: 900)

        Window("Display", id: "display") {
            PlayerDisplayView()
                .environment(gameState)
        }
        .defaultSize(width: 1920, height: 1080)
    }
}
