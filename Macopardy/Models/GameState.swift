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
    var phase: GamePhase = .board

    init(rounds: [JeopardyBoard], currentRound: Int, teams: [Team]) {
        game = Game(
            rounds: rounds,
            currentRound: currentRound,
            teams: teams
        )
    }

    convenience init() {
        self.init(
            rounds: [JeopardyBoard.sample],
            currentRound: 0,
            teams: Team.sampleTeams
        )
    }

    func selectQuestion(_ question: Question, categoryTitle: String) {
        markQuestionPlayed(question)
        currentQuestion = question
        currentCategoryTitle = categoryTitle
        phase = question.isDailyDouble ? .dailyDouble : .question
        timer.reset()
    }

    func revealAnswer() {
        phase = .answer
    }

    func showBoard() {
        phase = .board
        currentQuestion = nil
        currentCategoryTitle = nil
    }

    func showDailyDouble() {
        phase = .dailyDouble
    }

    func showFinalJeopardy(categoryTitle: String) {
        currentCategoryTitle = categoryTitle
        currentQuestion = nil
        phase = .finalJeopardy
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
        guard game.currentRound < game.rounds.count - 1 else { return }
        game.currentRound += 1
        showBoard()
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
