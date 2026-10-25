//
//  BuzzerStatusButton.swift
//  Macopardy
//
//  Toolbar button showing the join code and how many teams have a phone.
//  Opens a popover with join info and each team's phone.
//

import SwiftUI

struct BuzzerStatusButton: View {

    @Environment(GameState.self) var gameState
    @Environment(BuzzerState.self) var buzzerState

    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(title)
            }
        }
        .help("control.toolbar.buzzers.help")
        .popover(isPresented: $isPresented, arrowEdge: .bottom) {
            popoverContent()
        }
    }
}

#Preview {
    BuzzerStatusButton()
        .environment(GameState())
        .environment(BuzzerState())
        .padding()
}
