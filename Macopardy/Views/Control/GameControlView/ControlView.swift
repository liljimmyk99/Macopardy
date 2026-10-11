//
//  ControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

import SwiftUI

struct ControlView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            ScrollView {
                detailContent
            }
            .navigationTitle(navigationTitleText)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Text(phaseIndicator)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(JeopardyTheme.gold.opacity(0.2))
                        .foregroundStyle(JeopardyTheme.gold)
                        .clipShape(Capsule())
                }
            }
        }
        .background(JeopardyTheme.controlBackground)
    }

    @ViewBuilder
    private var detailContent: some View {
        switch gameState.phase {
        case .setup:
            SetupControlView()

        case .board:
            BoardControlView()

        case .question, .answer:
            QuestionControlView()

        case .dailyDouble:
            DailyDoubleControlView()

        case .finalJeopardyCategory:
            FinalJeopardyCategoryControlView()

        case .finalJeopardyQuestion, .finalJeopardyAnswer:
            FinalJeopardyControlView()
        }
    }

    private var navigationTitleText: String {
        switch gameState.phase {
        case .setup: "Phase 1: Setup"
        case .board: "Phase 2: Board"
        case .question, .answer: "Phase 3: Question"
        case .dailyDouble: "Phase 4: Daily Double"
        case .finalJeopardyCategory: "Phase 5: Final Jeopardy"
        case .finalJeopardyQuestion, .finalJeopardyAnswer: "Phase 6: Final Jeopardy Question"
        }
    }

    private var phaseIndicator: String {
        switch gameState.phase {
        case .setup: "Phase 1 - Game Load"
        case .board: "Phase 2 - Board"
        case .question: "Phase 3 - Question"
        case .answer: "Phase 3 - Answer Revealed"
        case .dailyDouble: "Phase 4 - Daily Double"
        case .finalJeopardyCategory: "Phase 5 - FJ Category"
        case .finalJeopardyQuestion: "Phase 6 - FJ Question"
        case .finalJeopardyAnswer: "Phase 6 - FJ Answer"
        }
    }
}

#Preview {
    ControlView()
        .environment(GameState())
        .frame(width: 1200, height: 900)
}
