//
//  DraftBoardControls.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/8/26.
//

import SwiftUI

struct DraftBoardControls: View {
    @Binding var currentRound: Int
    let saveGame: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if currentRound > 0 {
                Button(previousRoundLabel) {
                    currentRound -= 1
                }
                .buttonStyle(.bordered)
            }

            if currentRound < 2 {
                Button(nextRoundLabel) {
                    currentRound += 1
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            Button("create.button.save_game") {
                saveGame()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut("s", modifiers: .command)
            .controlSize(.large)
        }
    }

    private var previousRoundLabel: LocalizedStringKey {
        switch currentRound {
        case 1: "create.draft.previous_round.macpardy"
        case 2: "create.draft.previous_round.double_macpardy"
        default: "create.draft.previous_round"
        }
    }

    private var nextRoundLabel: LocalizedStringKey {
        switch currentRound {
        case 0: "create.draft.next_round.double_macpardy"
        case 1: "create.draft.next_round.final_macpardy"
        default: "create.draft.next_round"
        }
    }
}
