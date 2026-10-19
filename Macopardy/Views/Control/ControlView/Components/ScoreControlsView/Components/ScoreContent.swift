import SwiftUI

extension ScoreControlsView {
    @ViewBuilder
    func scoreContent() -> some View {
        if let ddTeamID = gameState.dailyDoubleTeamID,
           let team = gameState.game.teams.first(where: { $0.id == ddTeamID }) {
            dailyDoubleTeamControls(for: team, wager: gameState.dailyDoubleWager)
        } else if gameState.phase == .finalMacpardyQuestion || gameState.phase == .finalMacpardyAnswer {
            ForEach(gameState.game.teams) { team in
                let wager = gameState.finalMacpardyWagers[team.id] ?? 0
                finalMacpardyTeamControls(for: team, wager: wager)
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
                Text("control.score.daily_double_wager \(wager)")
                    .font(.caption.bold())
                    .foregroundStyle(MacpardyTheme.gold)

                Spacer()

                scoreButton(title: "control.score.button.correct_wager \(wager)", for: team, amount: wager, isCorrect: true)
                scoreButton(title: "control.score.button.wrong_wager \(wager)", for: team, amount: -wager, isCorrect: false)
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    func finalMacpardyTeamControls(for team: Team, wager: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            teamHeader(team)

            HStack(spacing: 8) {
                Text("control.score.fj_wager \(wager)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                Spacer()

                scoreButton(title: "control.score.button.correct_wager \(wager)", for: team, amount: wager, isCorrect: true)
                scoreButton(title: "control.score.button.wrong_wager \(wager)", for: team, amount: -wager, isCorrect: false)
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
                    scoreButton(title: "control.score.button.correct_value \(value)", for: team, amount: value, isCorrect: true)
                    scoreButton(title: "control.score.button.wrong_value \(value)", for: team, amount: -value, isCorrect: false)
                } else {
                    scoreButton(title: "control.score.amount.plus_100", for: team, amount: 100)
                    scoreButton(title: "control.score.amount.minus_100", for: team, amount: -100)
                    scoreButton(title: "control.score.amount.plus_200", for: team, amount: 200)
                    scoreButton(title: "control.score.amount.minus_200", for: team, amount: -200)

                    Button("control.score.button.reset") {
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

    func scoreButton(title: LocalizedStringKey, for team: Team, amount: Int, isCorrect: Bool? = nil) -> some View {
        Button(title) {
            gameState.adjustScore(for: team.id, by: amount)
        }
        .buttonStyle(.bordered)
        .tint(isCorrect == true ? .green : (isCorrect == false ? .red : nil))
        .frame(maxWidth: .infinity)
    }
}
