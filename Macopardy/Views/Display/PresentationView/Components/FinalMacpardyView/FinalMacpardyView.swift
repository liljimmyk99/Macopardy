import SwiftUI

struct FinalMacpardyView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        finalMacpardyContent()
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentCategoryTitle = "Think Music"
    gameState.phase = .finalMacpardyCategory

    return FinalMacpardyView()
        .environment(gameState)
        .frame(width: 960, height: 540)
}
