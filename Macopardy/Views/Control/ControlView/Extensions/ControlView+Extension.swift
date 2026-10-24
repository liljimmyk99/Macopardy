//
//  ControlView+Extension.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//

import SwiftUI

extension ControlView {
    var navigationTitleText: LocalizedStringKey {
        selection == .buzzer ? "control.nav_title.buzzer" : phaseNavigationTitle
    }

    private var phaseNavigationTitle: LocalizedStringKey {
        switch gameState.phase {
        case .setup: "control.nav_title.setup"
        case .board: "control.nav_title.board"
        case .question, .answer: "control.nav_title.question"
        case .dailyDouble: "control.nav_title.daily_double"
        case .finalMacpardyCategory: "control.nav_title.final_macpardy_category"
        case .finalMacpardyQuestion, .finalMacpardyAnswer: "control.nav_title.final_macpardy_question"
        }
    }

    var phaseIndicator: LocalizedStringKey {
        switch gameState.phase {
        case .setup: "control.phase_indicator.setup"
        case .board: "control.phase_indicator.board"
        case .question: "control.phase_indicator.question"
        case .answer: "control.phase_indicator.answer"
        case .dailyDouble: "control.phase_indicator.daily_double"
        case .finalMacpardyCategory: "control.phase_indicator.final_macpardy_category"
        case .finalMacpardyQuestion: "control.phase_indicator.final_macpardy_question"
        case .finalMacpardyAnswer: "control.phase_indicator.final_macpardy_answer"
        }
    }
}
