import SwiftUI

extension FinalMacpardyCategoryControlView {
    func finalMacpardyHeader() -> some View {
        VStack(spacing: 8) {
            Text("display.final_macpardy.header")
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(MacpardyTheme.gold)

            if let category = gameState.currentCategoryTitle {
                Text("control.daily_double.label_category \(category)")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }

            Text("control.final_macpardy.subtitle_status")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 10)
    }

    func teamWagerGroup() -> some View {
        GroupBox("control.final_macpardy.team_wagers_group") {
            VStack(spacing: 16) {
                ForEach(gameState.game.teams, id: \.id) { team in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(team.displayColor)
                            .frame(width: 14, height: 14)

                        Text(team.name)
                            .fontWeight(.semibold)

                        Spacer()

                        Text("control.final_macpardy.current_score \(team.score)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack {
                            Text("$")
                                .foregroundStyle(.secondary)

                            TextField("control.daily_double.wager_placeholder", text: Binding(
                                get: { wagers[team.id] ?? "" },
                                set: { wagers[team.id] = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                            .font(.monospacedDigit(.body)())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .frame(maxWidth: 600)
    }

    func revealQuestionButton() -> some View {
        LargeButton(
            title: "control.final_macpardy.button.reveal_question",
            systemImage: "questionmark.circle.fill",
            tint: MacpardyTheme.gold
        ) {
            for team in gameState.game.teams {
                let text = wagers[team.id] ?? ""
                let parsed = Int(text) ?? 0
                let maxAllowed = max(0, team.score)
                gameState.finalMacpardyWagers[team.id] = min(max(0, parsed), maxAllowed)
            }
            gameState.revealFinalMacpardyQuestion()
        }
        .frame(maxWidth: 300)
    }

    func syncWagersFromGameState() {
        for team in gameState.game.teams {
            let existing = gameState.finalMacpardyWagers[team.id] ?? 0
            wagers[team.id] = "\(existing)"
        }
    }
}
