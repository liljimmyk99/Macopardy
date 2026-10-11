import SwiftUI

struct QuestionView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        questionContent()
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentQuestion = JeopardyBoard.sample.categories[0].questions[0]
    gameState.currentCategoryTitle = "Science"
    gameState.phase = .question

    return QuestionView()
        .environment(gameState)
        .frame(width: 960, height: 540)
}
