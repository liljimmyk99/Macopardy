import SwiftUI

extension FinalMacpardyView {
    @ViewBuilder
    func finalMacpardyAnswer() -> some View {
        if let question = gameState.currentQuestion {
            Text(question.response)
                .font(MacpardyTheme.answerFont)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
        }
    }
}
