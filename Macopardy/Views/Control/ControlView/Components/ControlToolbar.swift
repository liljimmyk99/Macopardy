//
//  ControlToolbar.swift
//  Macopardy
//
//  Window toolbar: buzzers, the Display window, and the board's round actions.
//

import SwiftUI

extension ControlView {
    @ToolbarContentBuilder
    var controlToolbar: some ToolbarContent {
        if gameState.phase == .question || gameState.phase == .answer {
            ToolbarItem(placement: .navigation) {
                Button("control.question.button.return_to_board", systemImage: "chevron.backward") {
                    gameState.showBoard()
                }
                .labelStyle(.titleAndIcon)
                .keyboardShortcut("b", modifiers: .command)
            }
        }

        ToolbarItem(placement: .primaryAction) {
            BuzzerStatusButton()
        }

        ToolbarItem(placement: .primaryAction) {
            Button("control.toolbar.show_display", systemImage: "display") {
                openWindow(id: "display")
            }
            .labelStyle(.titleAndIcon)
            .keyboardShortcut("d", modifiers: .command)
            .help("control.toolbar.show_display.help")
        }

        if gameState.phase == .board {
            ToolbarSpacer(.fixed, placement: .primaryAction)

            ToolbarItem(placement: .primaryAction) {
                Button("round.final_macpardy", systemImage: "flag.checkered") {
                    gameState.showFinalMacpardy()
                }
                .labelStyle(.titleAndIcon)
                .keyboardShortcut("f", modifiers: .command)
                .foregroundStyle(MacpardyTheme.gold)
            }

            ToolbarItem(placement: .primaryAction) {
                Button("control.board.button.next_round", systemImage: "forward.fill") {
                    gameState.advanceRound()
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(.borderedProminent)
                .tint(MacpardyTheme.gold)
                .keyboardShortcut(.rightArrow, modifiers: .command)
                .foregroundStyle(MacpardyTheme.boardBlue)
            }
        }
    }
}
