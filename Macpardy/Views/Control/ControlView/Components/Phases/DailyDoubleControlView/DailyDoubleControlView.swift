import SwiftUI

struct DailyDoubleControlView: View {

    @Environment(GameState.self) var gameState

    @State var selectedTeamID: UUID?
    @State var wagerText: String = ""

    var selectedTeam: Team? {
        if let id = selectedTeamID {
            return gameState.game.teams.first(where: { $0.id == id })
        }
        return gameState.game.teams.first
    }

    var maxWager: Int {
        guard let team = selectedTeam else { return 1000 }
        let roundMax = (gameState.game.currentBoard?.round == .doubleMacpardy) ? 2000 : 1000
        return max(team.score, roundMax)
    }

    var body: some View {
        VStack(spacing: 24) {
            dailyDoubleHeader()
            dailyDoubleWagerGroupBox()
            showQuestionButton()
            Spacer()
        }
        .padding()
        .onAppear {
            if selectedTeamID == nil {
                selectedTeamID = gameState.game.teams.first?.id
            }
            let initialWager = gameState.currentQuestion?.value ?? 1000
            wagerText = "\(initialWager)"
        }
    }
}

#Preview {
    let gameState = GameState()
    gameState.currentQuestion = Question(value: 800, clue: "Clue", response: "Answer", isDailyDouble: true)
    gameState.currentCategoryTitle = "Science"
    gameState.phase = .dailyDouble

    return DailyDoubleControlView()
        .environment(gameState)
}
