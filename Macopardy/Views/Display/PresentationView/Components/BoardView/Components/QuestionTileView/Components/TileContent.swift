import SwiftUI

extension QuestionTileView {
    func tileContent() -> some View {
        ZStack {
            Rectangle()
                .fill(question.hasBeenPlayed ? MacpardyTheme.tilePlayed : MacpardyTheme.tileBlue)

            if !question.hasBeenPlayed {
                QuestionValueView(value: question.value)
            }
        }
        .aspectRatio(1.4, contentMode: .fit)
    }
}
