import SwiftUI

struct AnswerView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        answerContent()
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentQuestion = MacpardyBoard.sample.categories[0].questions[0]
    gameState.phase = .answer

    return AnswerView()
        .environment(gameState)
        .frame(width: 960, height: 540)
}
