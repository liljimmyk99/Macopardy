import SwiftUI

extension QuestionView {
    func questionClue(_ clue: String) -> some View {
        Text(clue)
            .font(MacpardyTheme.clueFont)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 60)
    }
}
