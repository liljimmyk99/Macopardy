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
            
            Button("Save Game") {
                saveGame()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    private var previousRoundLabel: String {
        switch currentRound {
        case 1: "Previous: Jeopardy"
        case 2: "Previous: Double Jeopardy"
        default: "Previous Round"
        }
    }

    private var nextRoundLabel: String {
        switch currentRound {
        case 0: "Next: Double Jeopardy"
        case 1: "Next: Final Jeopardy"
        default: "Next Round"
        }
    }
}
