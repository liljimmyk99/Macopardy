//
//  BuzzerControlView.swift
//  Macopardy
//
//  Buzzer tab: join info, per-team phone status, remove and re-add.
//

import SwiftUI

struct BuzzerControlView: View {

    @Environment(GameState.self) var gameState
    @Environment(BuzzerState.self) var buzzerState

    var body: some View {
        buzzerControlContent()
    }
}

#Preview {
    BuzzerControlView()
        .environment(GameState())
        .environment(BuzzerState())
        .frame(width: 800, height: 700)
}
