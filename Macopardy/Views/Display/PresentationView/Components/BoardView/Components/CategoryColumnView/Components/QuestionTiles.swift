import SwiftUI

extension CategoryColumnView {
    func questionTiles() -> some View {
        ForEach(category.questions) { question in
            QuestionTileView(question: question)
        }
    }
}
