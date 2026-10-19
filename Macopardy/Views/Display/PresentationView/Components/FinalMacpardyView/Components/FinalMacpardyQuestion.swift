import SwiftUI

extension FinalMacpardyView {
    @ViewBuilder
    func finalMacpardyQuestion() -> some View {
        if let question = gameState.currentQuestion {
            Text(question.clue)
                .font(MacpardyTheme.clueFont)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
        }
    }
}
