import SwiftUI

extension PresentationView {
    @ViewBuilder
    var phaseContent: some View {
        switch gameState.phase {
        case .setup:
            setupPhaseContent()

        case .board:
            if let board = gameState.game.currentBoard {
                BoardView(board: board)
            }

        case .question:
            QuestionView()

        case .answer:
            AnswerView()

        case .dailyDouble:
            DailyDoubleView()

        case .finalJeopardyCategory, .finalJeopardyQuestion, .finalJeopardyAnswer:
            FinalJeopardyView()
        }
    }
}
