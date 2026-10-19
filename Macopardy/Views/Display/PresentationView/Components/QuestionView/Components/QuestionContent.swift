import SwiftUI

extension QuestionView {
    @ViewBuilder
    func questionContent() -> some View {
        if let question = gameState.currentQuestion {
            VStack(spacing: 40) {
                Spacer()
                questionHeading(for: question)
                questionClue(question.clue)
                TimerView()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(MacpardyTheme.clueBackground)
            .onAppear {
                gameState.timer.start()
            }
        }
    }
}
