//
//  ScoreControlsView.swift
//  Macopardy
//

import SwiftUI

struct ScoreControlsView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        GroupBox("Scores") {
            VStack(spacing: 16) {
                ForEach(gameState.game.teams) { team in
                    teamControls(for: team)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func teamControls(for team: Team) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(team.displayColor)
                    .frame(width: 12, height: 12)

                Text(team.name)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(team.score)")
                    .font(.title3.monospacedDigit())
                    .fontWeight(.bold)
            }

            HStack(spacing: 6) {
                if let value = gameState.currentQuestion?.value {
                    scoreButton("Correct", for: team, amount: value)
                    scoreButton("Wrong", for: team, amount: (value * -1))
                } else {
                    scoreButton("+100", for: team, amount: 100)
                    scoreButton("-100", for: team, amount: -100)
                    scoreButton("+200", for: team, amount: 200)
                    scoreButton("-200", for: team, amount: -200)
                    
                    Button("Reset") {
                        gameState.resetScore(for: team.id)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func scoreButton(_ title: String, for team: Team, amount: Int) -> some View {
        Button(title) {
            gameState.adjustScore(for: team.id, by: amount)
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScoreControlsView()
        .environment(GameState())
        .padding()
        .frame(width: 500)
}
