//
//  SidebarView+Extension.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

extension SidebarView {
    var phaseLabel: String {
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

    var phaseIcon: String {
        switch gameState.phase {
        case .setup: "person.3.fill"
        case .board: "square.grid.3x3"
        case .question, .answer: "questionmark.circle.fill"
        case .dailyDouble: "star.fill"
        case .finalJeopardyCategory, .finalJeopardyQuestion, .finalJeopardyAnswer: "flag.checkered"
        }
    }
}
