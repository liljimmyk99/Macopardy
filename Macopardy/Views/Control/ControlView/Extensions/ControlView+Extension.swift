//
//  ControlView+Extension.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

extension ControlView {
    var navigationTitleText: LocalizedStringKey {
        switch gameState.phase {
        case .setup: "control.nav_title.setup"
        case .board: "control.nav_title.board"
        case .question, .answer: "control.nav_title.question"
        case .dailyDouble: "control.nav_title.daily_double"
        case .finalJeopardyCategory: "control.nav_title.final_jeopardy_category"
        case .finalJeopardyQuestion, .finalJeopardyAnswer: "control.nav_title.final_jeopardy_question"
        }
    }

    var phaseIndicator: LocalizedStringKey {
        switch gameState.phase {
        case .setup: "control.phase_indicator.setup"
        case .board: "control.phase_indicator.board"
        case .question: "control.phase_indicator.question"
        case .answer: "control.phase_indicator.answer"
        case .dailyDouble: "control.phase_indicator.daily_double"
        case .finalJeopardyCategory: "control.phase_indicator.final_jeopardy_category"
        case .finalJeopardyQuestion: "control.phase_indicator.final_jeopardy_question"
        case .finalJeopardyAnswer: "control.phase_indicator.final_jeopardy_answer"
        }
    }
}
