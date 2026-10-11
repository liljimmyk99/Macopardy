import SwiftUI

struct FinalJeopardyView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        finalJeopardyContent()
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentCategoryTitle = "Think Music"
    gameState.phase = .finalJeopardyCategory

    return FinalJeopardyView()
        .environment(gameState)
        .frame(width: 960, height: 540)
}
