//
//  GameState.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//
import Foundation

@Observable
final class GameState {
    var game: Game

    // UI State
    var currentQuestion: Question?
    var currentCategoryTitle: String?
    var timer = GameTimer()
    var phase: GamePhase = .setup

    // Daily Double State
    var dailyDoubleTeamID: UUID?
    var dailyDoubleWager: Int = 0

    // Final Jeopardy State
    var finalJeopardyWagers: [UUID: Int] = [:]

    init(rounds: [JeopardyBoard], currentRound: Int = 0, teams: [Team] = Team.defaultNewTeams, phase: GamePhase = .setup) {
        self.game = Game(
            rounds: rounds,
            currentRound: currentRound,
            teams: teams
        )
        self.phase = phase
    }

    convenience init() {
        self.init(
            rounds: [JeopardyBoard.sample],
            currentRound: 0,
            teams: Team.defaultNewTeams,
            phase: .setup
        )
    }

    func startGame() {
        phase = .board
    }

    func selectQuestion(_ question: Question, categoryTitle: String) {
        markQuestionPlayed(question)
        currentQuestion = question
        currentCategoryTitle = categoryTitle
        if question.isDailyDouble {
            dailyDoubleTeamID = game.teams.first?.id
            dailyDoubleWager = max(question.value, 1000)
            phase = .dailyDouble
        } else {
            dailyDoubleTeamID = nil
            dailyDoubleWager = 0
            phase = .question
            timer.reset()
        }
    }

    func submitDailyDoubleWager(teamID: UUID, wager: Int) {
        dailyDoubleTeamID = teamID
        dailyDoubleWager = wager
        phase = .question
        timer.reset()
    }

    func revealAnswer() {
        if phase == .finalJeopardyQuestion {
            phase = .finalJeopardyAnswer
        } else {
            phase = .answer
        }
    }

    func showBoard() {
        phase = .board
        currentQuestion = nil
        currentCategoryTitle = nil
        dailyDoubleTeamID = nil
        dailyDoubleWager = 0
    }

    func showDailyDouble() {
        phase = .dailyDouble
    }

    func showFinalJeopardy(categoryTitle: String? = nil) {
        // Look up final jeopardy board if present
        if let fjBoard = game.rounds.first(where: { $0.round == .finalJeopardy }),
           let category = fjBoard.categories.first,
           let question = category.questions.first {
            currentCategoryTitle = category.title
            currentQuestion = question
        } else if let title = categoryTitle {
            currentCategoryTitle = title
            currentQuestion = Question(value: 0, clue: "Final Jeopardy Clue", response: "Final Jeopardy Response")
        } else {
            currentCategoryTitle = "Final Jeopardy"
            currentQuestion = Question(value: 0, clue: "Final Jeopardy Clue", response: "Final Jeopardy Response")
        }

        // Initialize team wagers with 0
        finalJeopardyWagers = Dictionary(uniqueKeysWithValues: game.teams.map { ($0.id, 0) })
        phase = .finalJeopardyCategory
        timer.reset()
    }

    func revealFinalJeopardyQuestion() {
        phase = .finalJeopardyQuestion
        timer.reset()
    }

    func adjustScore(for teamID: UUID, by amount: Int) {
        guard let index = game.teams.firstIndex(where: { $0.id == teamID }) else { return }
        game.teams[index].score += amount
    }

    func resetScore(for teamID: UUID) {
        guard let index = game.teams.firstIndex(where: { $0.id == teamID }) else { return }
        game.teams[index].score = 0
    }

    func advanceRound() {
        // Find next non-final-jeopardy board or next round index
        let nextRound = game.currentRound + 1
        if nextRound < game.rounds.count {
            if game.rounds[nextRound].round == .finalJeopardy {
                showFinalJeopardy()
            } else {
                game.currentRound = nextRound
                showBoard()
            }
        }
    }

    func loadGame(boards: [JeopardyBoard]) {
        self.game = Game(
            rounds: boards,
            currentRound: 0,
            teams: Team.defaultNewTeams
        )
        self.phase = .setup
        self.currentQuestion = nil
        self.currentCategoryTitle = nil
        self.dailyDoubleTeamID = nil
        self.dailyDoubleWager = 0
        self.finalJeopardyWagers = [:]
    }

    func addTeam(name: String = "", color: String = "blue") {
        let count = game.teams.count + 1
        let teamName = name.isEmpty ? "Team \(count)" : name
        let availableColors = ["blue", "red", "green", "yellow", "purple", "orange"]
        let chosenColor = availableColors[(count - 1) % availableColors.count]
        game.teams.append(Team(name: teamName, score: 0, color: chosenColor))
    }

    func removeTeam(at index: Int) {
        guard game.teams.indices.contains(index) else { return }
        game.teams.remove(at: index)
    }

    func removeTeam(id: UUID) {
        game.teams.removeAll(where: { $0.id == id })
    }

    func removeTeam(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            if game.teams.indices.contains(index) {
                game.teams.remove(at: index)
            }
        }
    }

    private func markQuestionPlayed(_ question: Question) {
        guard let roundIndex = game.rounds.indices.first(where: { $0 == game.currentRound }) else { return }

        for categoryIndex in game.rounds[roundIndex].categories.indices {
            for questionIndex in game.rounds[roundIndex].categories[categoryIndex].questions.indices {
                if game.rounds[roundIndex].categories[categoryIndex].questions[questionIndex].id == question.id {
                    game.rounds[roundIndex].categories[categoryIndex].questions[questionIndex].hasBeenPlayed = true
                    return
                }
            }
        }
    }
}
