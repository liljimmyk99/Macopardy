import SwiftUI

extension FinalJeopardyView {
    @ViewBuilder
    func finalJeopardyPhaseContent() -> some View {
        switch gameState.phase {
        case .finalJeopardyCategory:
            EmptyView()

        case .finalJeopardyQuestion:
            finalJeopardyQuestion()
            TimerView()
                .onAppear {
                    gameState.timer.start()
                }

        case .finalJeopardyAnswer:
            finalJeopardyAnswer()

        default:
            EmptyView()
        }
    }
}
