import SwiftUI

extension QuestionPickerView {
    func questionButton(_ question: Question, categoryTitle: String) -> some View {
        Button {
            gameState.selectQuestion(question, categoryTitle: categoryTitle)
        } label: {
            VStack(spacing: 4) {
                Text("$\(question.value)")
                    .fontWeight(.bold)

                if question.hasBeenPlayed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.secondary)
                } else if question.isDailyDouble {
                    Text("DD")
                        .font(.caption2.bold())
                        .foregroundStyle(JeopardyTheme.gold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
        .disabled(question.hasBeenPlayed)
    }
}
