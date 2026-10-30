//
//  ControlViewContent.swift
//  Macpardy
//
//  Created by Jimmy Kane on 10/10/26.
//
import SwiftUI

extension ControlView {
    /// Setup, the board and the clue fill the window like the Display does; other phases scroll.
    @ViewBuilder
    var detailContent: some View {
        if fillsWindow {
            phaseContent
        } else {
            ScrollView {
                phaseContent
            }
        }
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch gameState.phase {
        case .setup:
            SetupControlView()

        case .board:
            BoardControlView()

        case .question, .answer:
            QuestionControlView()

        case .dailyDouble:
            DailyDoubleControlView()

        case .finalMacpardyCategory:
            FinalMacpardyCategoryControlView()

        case .finalMacpardyQuestion, .finalMacpardyAnswer:
            FinalMacpardyControlView()
        }
    }
}
