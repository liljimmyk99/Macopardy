//
//  TimerControlsView.swift
//  Macopardy
//

import SwiftUI

struct TimerControlsView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        GroupBox("Timer") {
            VStack(spacing: 12) {
                HStack {
                    Text("Remaining")
                    Spacer()
                    Text("\(gameState.timer.remainingTime)s")
                        .font(.title2.monospacedDigit())
                        .fontWeight(.semibold)
                }

                HStack(spacing: 8) {
                    controlButton("Start", systemImage: "play.fill") {
                        gameState.timer.start()
                    }

                    controlButton("Pause", systemImage: "pause.fill") {
                        gameState.timer.stop()
                    }

                    controlButton("Reset", systemImage: "arrow.counterclockwise") {
                        gameState.timer.reset()
                    }
                }

                HStack(spacing: 8) {
                    controlButton("+5", systemImage: "plus") {
                        gameState.timer.addSeconds(5)
                    }

                    controlButton("-5", systemImage: "minus") {
                        gameState.timer.addSeconds(-5)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func controlButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}

#Preview {
    TimerControlsView()
        .environment(GameState())
        .padding()
        .frame(width: 400)
}
