import SwiftUI

struct TimerView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        countdownContent()
    }
}

#Preview {
    TimerView()
        .environment(GameState())
        .padding()
        .background(JeopardyTheme.clueBackground)
}
