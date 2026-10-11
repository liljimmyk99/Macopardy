//
//  TimerControlsView.swift
//  Macopardy
//

import SwiftUI

struct TimerControlsView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        GroupBox("Timer") {
            VStack(spacing: 12) {
                timerDisplayRow()
                timerPlaybackControls()
                timerAdjustmentControls()
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    TimerControlsView()
        .environment(GameState())
        .padding()
        .frame(width: 400)
}
