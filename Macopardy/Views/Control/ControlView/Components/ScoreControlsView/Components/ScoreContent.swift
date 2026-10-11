import SwiftUI

extension ScoreControlsView {
    @ViewBuilder
    func scoreContent() -> some View {
        if let ddTeamID = gameState.dailyDoubleTeamID,
           let team = gameState.game.teams.first(where: { $0.id == ddTeamID }) {
            dailyDoubleTeamControls(for: team, wager: gameState.dailyDoubleWager)
        } else if gameState.phase == .finalJeopardyQuestion || gameState.phase == .finalJeopardyAnswer {
            ForEach(gameState.game.teams) { team in
                let wager = gameState.finalJeopardyWagers[team.id] ?? 0
                finalJeopardyTeamControls(for: team, wager: wager)
            }
        } else {
            ForEach(gameState.game.teams) { team in
                standardTeamControls(for: team)
            }
        }
    }

    func dailyDoubleTeamControls(for team: Team, wager: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            teamHeader(team)

            HStack(spacing: 8) {
                Text("Daily Double Wager: \(wager)")
                    .font(.caption.bold())
                    .foregroundStyle(JeopardyTheme.gold)

                Spacer()

                scoreButton("Correct (+\(wager))", for: team, amount: wager, isCorrect: true)
                scoreButton("Wrong (-\(wager))", for: team, amount: -wager, isCorrect: false)
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    func finalJeopardyTeamControls(for team: Team, wager: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            teamHeader(team)

            HStack(spacing: 8) {
                Text("FJ Wager: \(wager)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                Spacer()

                scoreButton("Correct (+\(wager))", for: team, amount: wager, isCorrect: true)
                scoreButton("Wrong (-\(wager))", for: team, amount: -wager, isCorrect: false)
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    func standardTeamControls(for team: Team) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            teamHeader(team)

            HStack(spacing: 6) {
                if let value = gameState.currentQuestion?.value {
                    scoreButton("Correct (+\(value))", for: team, amount: value, isCorrect: true)
                    scoreButton("Wrong (-\(value))", for: team, amount: -value, isCorrect: false)
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

    func teamHeader(_ team: Team) -> some View {
        HStack {
            Circle()
                .fill(team.displayColor)
                .frame(width: 12, height: 12)

            Text(team.name)
                .fontWeight(.semibold)

            Spacer()

            Text("$\(team.score)")
                .font(.title3.monospacedDigit())
                .fontWeight(.bold)
        }
    }

    func scoreButton(_ title: String, for team: Team, amount: Int, isCorrect: Bool? = nil) -> some View {
        Button(title) {
            gameState.adjustScore(for: team.id, by: amount)
        }
        .buttonStyle(.bordered)
        .tint(isCorrect == true ? .green : (isCorrect == false ? .red : nil))
        .frame(maxWidth: .infinity)
    }
}
