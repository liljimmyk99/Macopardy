//
//  SidebarView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct SidebarView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        List {
            Section("Round") {
                if let board = gameState.game.currentBoard {
                    Label(board.title, systemImage: "rectangle.grid.3x2")
                    Text(board.round.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No Active Round")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Phase") {
                HStack {
                    Image(systemName: phaseIcon)
                        .foregroundStyle(JeopardyTheme.gold)
                    Text(phaseLabel)
                        .fontWeight(.medium)
                }
            }

            Section("Teams & Standings") {
                ForEach(gameState.game.teams) { team in
                    HStack {
                        Circle()
                            .fill(team.displayColor)
                            .frame(width: 10, height: 10)

                        Text(team.name)
                            .font(.body)

                        Spacer()

                        Text("$\(team.score)")
                            .font(.subheadline.monospacedDigit())
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Control Panel")
    }

    private var phaseLabel: String {
        switch gameState.phase {
        case .setup: "Phase 1: Setup"
        case .board: "Phase 2: Board"
        case .question: "Phase 3: Question"
        case .answer: "Phase 3: Answer"
        case .dailyDouble: "Phase 4: Daily Double"
        case .finalJeopardyCategory: "Phase 5: FJ Category"
        case .finalJeopardyQuestion: "Phase 6: FJ Question"
        case .finalJeopardyAnswer: "Phase 6: FJ Answer"
        }
    }

    private var phaseIcon: String {
        switch gameState.phase {
        case .setup: "person.3.fill"
        case .board: "square.grid.3x3"
        case .question, .answer: "questionmark.circle.fill"
        case .dailyDouble: "star.fill"
        case .finalJeopardyCategory, .finalJeopardyQuestion, .finalJeopardyAnswer: "flag.checkered"
        }
    }
}

#Preview {
    NavigationSplitView {
        SidebarView()
            .environment(GameState())
    } detail: {
        Text("Detail")
    }
}
