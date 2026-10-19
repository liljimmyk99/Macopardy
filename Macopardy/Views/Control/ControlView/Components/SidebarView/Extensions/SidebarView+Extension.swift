//
//  SidebarView+Extension.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

extension SidebarView {
    var phaseLabel: LocalizedStringKey {
        switch gameState.phase {
        case .setup: "control.phase.setup"
        case .board: "control.phase.board"
        case .question: "control.phase.question"
        case .answer: "control.phase.answer"
        case .dailyDouble: "control.phase.daily_double"
        case .finalJeopardyCategory: "control.phase.final_jeopardy_category"
        case .finalJeopardyQuestion: "control.phase.final_jeopardy_question"
        case .finalJeopardyAnswer: "control.phase.final_jeopardy_answer"
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
