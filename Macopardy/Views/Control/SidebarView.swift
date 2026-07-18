//
//  SidebarView.swift
//  Macopardy
//

import SwiftUI

enum ControlSection: String, CaseIterable, Identifiable {
    case categories = "Categories"
    case teams = "Teams"
    case game = "Game"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .categories: "square.grid.3x3"
        case .teams: "person.3"
        case .game: "gamecontroller"
        }
    }
}

struct SidebarView: View {

    @Binding var selection: ControlSection?

    @Environment(GameState.self) private var gameState

    var body: some View {
        List(selection: $selection) {
            Section("Navigation") {
                ForEach(ControlSection.allCases) { section in
                    Label(section.rawValue, systemImage: section.systemImage)
                        .tag(section)
                }
            }

            Section("Round") {
                if let board = gameState.game.currentBoard {
                    Label(board.title, systemImage: "rectangle.grid.3x2")
                    Text(board.round.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Phase") {
                Text(phaseLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Control")
    }

    private var phaseLabel: String {
        switch gameState.phase {
        case .board: "Board"
        case .question: "Question"
        case .answer: "Answer"
        case .dailyDouble: "Daily Double"
        case .finalJeopardy: "Final Jeopardy"
        }
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(selection: .constant(.categories))
            .environment(GameState())
    } detail: {
        Text("Detail")
    }
}
