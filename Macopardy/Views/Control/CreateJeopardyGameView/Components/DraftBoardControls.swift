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
        HStack {
            if currentRound < 2 {
                Button("Next Round") {
                    currentRound += 1
                }.buttonStyle(.bordered)
            }
            
            if currentRound > 0 {
                Button("Previous Round") {
                    currentRound -= 1
                }.buttonStyle(.bordered)
            }
            
            Spacer()
            
            Button("Save Game") {
                saveGame()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
    
}
