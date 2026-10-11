//
//  Phase4DailyDoubleControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

struct DailyDoubleControlView: View {

    @Environment(GameState.self) private var gameState

    @State private var selectedTeamID: UUID?
    @State private var wagerText: String = ""

    private var selectedTeam: Team? {
        if let id = selectedTeamID {
            return gameState.game.teams.first(where: { $0.id == id })
        }
        return gameState.game.teams.first
    }

    private var maxWager: Int {
        guard let team = selectedTeam else { return 1000 }
        let roundMax = (gameState.game.currentBoard?.round == .doubleJeopardy) ? 2000 : 1000
        return max(team.score, roundMax)
    }

    var body: some View {
        VStack(spacing: 24) {
            // Daily Double Header
            VStack(spacing: 8) {
                Text("DAILY DOUBLE!")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(JeopardyTheme.gold)

                if let category = gameState.currentCategoryTitle {
                    Text("Category: \(category)")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 10)

            GroupBox("Daily Double Wager") {
                VStack(spacing: 20) {
                    // Team Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Wagering Team:")
                            .font(.headline)

                        Picker("Team", selection: Binding(
                            get: { selectedTeamID ?? gameState.game.teams.first?.id ?? UUID() },
                            set: { selectedTeamID = $0 }
                        )) {
                            ForEach(gameState.game.teams) { team in
                                HStack {
                                    Circle()
                                        .fill(team.displayColor)
                                        .frame(width: 8, height: 8)
                                    Text("\(team.name) ($\(team.score))")
                                }
                                .tag(team.id)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Wager input
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Wager Amount:")
                                .font(.headline)
                            Spacer()
                            Text("Max Allowed: $\(maxWager)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("$")
                                .font(.title2.bold())
                                .foregroundStyle(.secondary)

                            TextField("Wager", text: $wagerText)
                                .textFieldStyle(.roundedBorder)
                                .font(.title3.monospacedDigit())
                        }

                        // Quick wager buttons
                        HStack(spacing: 8) {
                            Button("Min ($5)") {
                                wagerText = "5"
                            }
                            .buttonStyle(.bordered)

                            if let clueValue = gameState.currentQuestion?.value {
                                Button("Clue Value ($\(clueValue))") {
                                    wagerText = "\(clueValue)"
                                }
                                .buttonStyle(.bordered)
                            }

                            Button("True Daily Double ($\(maxWager))") {
                                wagerText = "\(maxWager)"
                            }
                            .buttonStyle(.bordered)
                            .tint(JeopardyTheme.gold)
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: 550)

            // Show Question Button
            LargeButton(
                title: "Show Question",
                systemImage: "questionmark.circle.fill",
                tint: JeopardyTheme.gold
            ) {
                let teamID = selectedTeamID ?? gameState.game.teams.first?.id ?? UUID()
                let parsedWager = Int(wagerText) ?? (gameState.currentQuestion?.value ?? 1000)
                let finalWager = max(5, min(parsedWager, maxWager))
                gameState.submitDailyDoubleWager(teamID: teamID, wager: finalWager)
            }
            .frame(maxWidth: 300)

            Spacer()
        }
        .padding()
        .onAppear {
            if selectedTeamID == nil {
                selectedTeamID = gameState.game.teams.first?.id
            }
            let initialWager = gameState.currentQuestion?.value ?? 1000
            wagerText = "\(initialWager)"
        }
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentQuestion = Question(value: 800, clue: "Clue", response: "Answer", isDailyDouble: true)
    gameState.currentCategoryTitle = "Science"
    gameState.phase = .dailyDouble

    return DailyDoubleControlView()
        .environment(gameState)
}
