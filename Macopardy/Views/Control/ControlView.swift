//
//  ControlView.swift
//  Macopardy
//

import SwiftUI

struct ControlView: View {

    @Environment(GameState.self) private var gameState

    @State private var sidebarSelection: ControlSection? = .categories

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $sidebarSelection)
        } detail: {
            detailContent
                .navigationTitle(sidebarSelection?.rawValue ?? "Control")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Text(phaseIndicator)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.quaternary)
                            .clipShape(Capsule())
                    }
                }
        }
        .background(JeopardyTheme.controlBackground)
    }

    @ViewBuilder
    private var detailContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                GameToolbar()

                switch sidebarSelection ?? .categories {
                case .categories:
                    categoriesContent

                case .teams:
                    TeamEditorView()
                    ScoreControlsView()

                case .game:
                    gameManagementContent
                }
            }
            .padding()
        }
    }

    private var categoriesContent: some View {
        VStack(spacing: 20) {
            QuestionPickerView()
            ScoreControlsView()
            TimerControlsView()
        }
    }

    private var gameManagementContent: some View {
        VStack(spacing: 20) {
            ScoreControlsView()
            TimerControlsView()
            TeamEditorView()
        }
    }

    private var phaseIndicator: String {
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
    ControlView()
        .environment(GameState())
        .frame(width: 1200, height: 900)
}
