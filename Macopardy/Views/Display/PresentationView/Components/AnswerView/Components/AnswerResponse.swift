import SwiftUI

extension AnswerView {
    func answerResponse(_ response: String) -> some View {
        Text(response)
            .font(JeopardyTheme.answerFont)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 60)
    }
}
