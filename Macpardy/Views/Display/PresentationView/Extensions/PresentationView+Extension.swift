import SwiftUI

extension PresentationView {
    @ViewBuilder
    var phaseContent: some View {
        switch gameState.phase {
        case .setup:
            setupPhaseContent()
                .transition(fade)

        case .board:
            if let board = gameState.game.currentBoard {
                BoardView(board: board)
                    .transition(fade)
            }

        case .question:
            QuestionView()
                .transition(.asymmetric(insertion: MacpardyMotion.flipIn(animated: animates), removal: fade))

        case .answer:
            AnswerView()
                .transition(.asymmetric(insertion: MacpardyMotion.flipIn(animated: animates), removal: fade))

        case .dailyDouble:
            DailyDoubleView()
                .transition(animates ? .scale(scale: 0.2).combined(with: .opacity) : .identity)

        case .finalMacpardyCategory, .finalMacpardyQuestion, .finalMacpardyAnswer:
            FinalMacpardyView()
                .transition(animates ? .move(edge: .trailing).combined(with: .opacity) : .identity)
        }
    }

    private var fade: AnyTransition {
        animates ? .opacity : .identity
    }
}
