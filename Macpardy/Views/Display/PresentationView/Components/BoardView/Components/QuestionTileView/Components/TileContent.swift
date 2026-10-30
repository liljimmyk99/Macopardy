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
        .rotation3DEffect(
            .degrees(isRevealed ? 0 : -90),
            axis: (x: 1, y: 0, z: 0),
            anchor: .top,
            perspective: 0.4
        )
        .opacity(isRevealed ? 1 : 0)
        .animation(MacpardyMotion.tileReveal(row: row), value: isRevealed)
    }
}
