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
        case .finalMacpardyCategory: "control.phase.final_macpardy_category"
        case .finalMacpardyQuestion: "control.phase.final_macpardy_question"
        case .finalMacpardyAnswer: "control.phase.final_macpardy_answer"
        }
    }

    var phaseIcon: String {
        switch gameState.phase {
        case .setup: "person.3.fill"
        case .board: "square.grid.3x3"
        case .question, .answer: "questionmark.circle.fill"
        case .dailyDouble: "star.fill"
        case .finalMacpardyCategory, .finalMacpardyQuestion, .finalMacpardyAnswer: "flag.checkered"
        }
    }
}
