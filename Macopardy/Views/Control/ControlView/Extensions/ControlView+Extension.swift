//
//  ControlView+Extension.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

extension ControlView {
    var navigationTitleText: String {
        switch gameState.phase {
        case .setup: "Phase 1: Setup"
        case .board: "Phase 2: Board"
        case .question, .answer: "Phase 3: Question"
        case .dailyDouble: "Phase 4: Daily Double"
        case .finalJeopardyCategory: "Phase 5: Final Jeopardy"
        case .finalJeopardyQuestion, .finalJeopardyAnswer: "Phase 6: Final Jeopardy Question"
        }
    }

    var phaseIndicator: String {
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
