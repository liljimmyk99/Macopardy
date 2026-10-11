//
//  ControlViewContent.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//
import SwiftUI

extension ControlView {
    @ViewBuilder
    var detailContent: some View {
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
}
