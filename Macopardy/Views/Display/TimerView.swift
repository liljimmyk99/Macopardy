//
//  TimerView.swift
//  Macopardy
//

import SwiftUI

struct TimerView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        CountdownView(seconds: Int(gameState.timer.remainingTime))
    }
}

#Preview {
    TimerView()
        .environment(GameState())
        .padding()
        .background(JeopardyTheme.clueBackground)
}
