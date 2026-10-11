import SwiftUI

extension AnswerView {
    @ViewBuilder
    func answerContent() -> some View {
        if let question = gameState.currentQuestion {
            VStack(spacing: 48) {
                Spacer()
                answerResponse(question.response)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(JeopardyTheme.clueBackground)
        }
    }
}
