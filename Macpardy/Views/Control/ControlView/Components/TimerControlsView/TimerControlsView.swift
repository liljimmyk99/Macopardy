//
//  TimerControlsView.swift
//  Macopardy
//

import SwiftUI

/// Countdown ring with −5 s, start/pause, reset and +5 s.
struct TimerControlsView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        VStack(spacing: 16) {
            timerDisplayRow()
            timerPlaybackControls()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MacpardyTheme.panelBlue)
    }
}

#Preview {
    TimerControlsView()
        .environment(GameState())
        .padding()
        .frame(width: 320, height: 320)
}
