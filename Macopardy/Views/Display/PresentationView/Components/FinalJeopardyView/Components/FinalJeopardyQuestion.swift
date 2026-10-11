import SwiftUI

extension FinalJeopardyView {
    @ViewBuilder
    func finalJeopardyQuestion() -> some View {
        if let question = gameState.currentQuestion {
            Text(question.clue)
                .font(JeopardyTheme.clueFont)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
        }
    }
}
