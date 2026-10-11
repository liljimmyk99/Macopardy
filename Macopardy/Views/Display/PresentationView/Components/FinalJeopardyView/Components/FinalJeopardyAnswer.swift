import SwiftUI

extension FinalJeopardyView {
    @ViewBuilder
    func finalJeopardyAnswer() -> some View {
        if let question = gameState.currentQuestion {
            Text(question.response)
                .font(JeopardyTheme.answerFont)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
        }
    }
}
