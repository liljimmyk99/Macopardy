import SwiftUI

extension QuestionView {
    @ViewBuilder
    func questionContent() -> some View {
        if let question = gameState.currentQuestion {
            Group {
                if let image = question.image {
                    // The clue keeps the space it needs (shrinking only if it
                    // must); the image fills whatever is left.
                    VStack(spacing: 24) {
                        questionHeading(for: question)
                        QuestionImageDisplay(image: image)
                            .frame(maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
                            .padding(.horizontal, 60)
                        questionClue(question.clue)
                            .minimumScaleFactor(0.5)
                            .layoutPriority(1)
                        TimerView()
                    }
                    .padding(.vertical, 32)
                } else {
                    VStack(spacing: 40) {
                        Spacer()
                        questionHeading(for: question)
                        questionClue(question.clue)
                        TimerView()
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(MacpardyTheme.clueBackground)
            .onAppear {
                gameState.timer.start()
            }
        }
    }
}
