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

    // Final Macpardy State
    var finalMacpardyWagers: [UUID: Int] = [:]

    // Persistence
    private var pendingSaveTask: Task<Void, Never>?
    var onSaveTriggered: ((GameSnapshot) -> Void)?

    init(rounds: [MacpardyBoard], currentRound: Int = 0, teams: [Team] = Team.defaultNewTeams, phase: GamePhase = .setup) {
        self.game = Game(
            rounds: rounds,
            currentRound: currentRound,
            teams: teams
        )
        self.phase = phase
    }

    convenience init() {
        self.init(
            rounds: [MacpardyBoard.sample],
            currentRound: 0,
            teams: Team.defaultNewTeams,
            phase: .setup
        )
    }

    convenience init(from snapshot: GameSnapshot) {
        self.init(
            rounds: snapshot.game.rounds,
            currentRound: snapshot.game.currentRound,
            teams: snapshot.game.teams,
            phase: snapshot.phase
        )
        self.dailyDoubleTeamID = snapshot.dailyDoubleTeamID
        self.dailyDoubleWager = snapshot.dailyDoubleWager
        self.finalMacpardyWagers = snapshot.finalMacpardyWagers
        self.currentCategoryTitle = snapshot.currentCategoryTitle
        if let qID = snapshot.currentQuestionID,
           snapshot.game.rounds.indices.contains(snapshot.game.currentRound) {
            let currentBoard = snapshot.game.rounds[snapshot.game.currentRound]
            for cat in currentBoard.categories {
                if let matched = cat.questions.first(where: { $0.id == qID }) {
                    self.currentQuestion = matched
                    break
                }
            }
        }
    }

    func restore(from snapshot: GameSnapshot) {
        self.game = snapshot.game
        self.phase = snapshot.phase
        self.dailyDoubleTeamID = snapshot.dailyDoubleTeamID
        self.dailyDoubleWager = snapshot.dailyDoubleWager
        self.finalMacpardyWagers = snapshot.finalMacpardyWagers
        self.currentCategoryTitle = snapshot.currentCategoryTitle
        self.currentQuestion = nil
        if let qID = snapshot.currentQuestionID,
           game.rounds.indices.contains(game.currentRound) {
            let currentBoard = game.rounds[game.currentRound]
            for cat in currentBoard.categories {
                if let matched = cat.questions.first(where: { $0.id == qID }) {
                    self.currentQuestion = matched
                    break
                }
            }
        }
        self.timer.reset()
    }

    func startGame() {
        phase = .board
        triggerSave()
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
        triggerSave()
    }

    func submitDailyDoubleWager(teamID: UUID, wager: Int) {
        dailyDoubleTeamID = teamID
        dailyDoubleWager = wager
        phase = .question
        timer.reset()
        triggerSave()
    }

    func revealAnswer() {
        if phase == .finalMacpardyQuestion {
            phase = .finalMacpardyAnswer
        } else {
            phase = .answer
        }
        triggerSave()
    }

    func showBoard() {
        phase = .board
        currentQuestion = nil
        currentCategoryTitle = nil
        dailyDoubleTeamID = nil
        dailyDoubleWager = 0
        triggerSave()
    }

    func showDailyDouble() {
        phase = .dailyDouble
        triggerSave()
    }

    func showFinalMacpardy(categoryTitle: String? = nil) {
        // Look up final macpardy board if present
        if let fjBoard = game.rounds.first(where: { $0.round == .finalMacpardy }),
           let category = fjBoard.categories.first,
           let question = category.questions.first {
            currentCategoryTitle = category.title
            currentQuestion = question
        } else if let title = categoryTitle {
            currentCategoryTitle = title
            currentQuestion = Question(value: 0, clue: "Final Macpardy Clue", response: "Final Macpardy Response")
        } else {
            currentCategoryTitle = "Final Macpardy"
            currentQuestion = Question(value: 0, clue: "Final Macpardy Clue", response: "Final Macpardy Response")
        }

        // Initialize team wagers with 0
        finalMacpardyWagers = Dictionary(uniqueKeysWithValues: game.teams.map { ($0.id, 0) })
        phase = .finalMacpardyCategory
        timer.reset()
        triggerSave()
    }

    func revealFinalMacpardyQuestion() {
        phase = .finalMacpardyQuestion
        timer.reset()
        triggerSave()
    }

    func adjustScore(for teamID: UUID, by amount: Int) {
        guard let index = game.teams.firstIndex(where: { $0.id == teamID }) else { return }
        game.teams[index].score += amount
        triggerSave()
    }

    func resetScore(for teamID: UUID) {
        guard let index = game.teams.firstIndex(where: { $0.id == teamID }) else { return }
        game.teams[index].score = 0
        triggerSave()
    }

    func advanceRound() {
        // Find next non-final-macpardy board or next round index
        let nextRound = game.currentRound + 1
        if nextRound < game.rounds.count {
            if game.rounds[nextRound].round == .finalMacpardy {
                showFinalMacpardy()
            } else {
                game.currentRound = nextRound
                showBoard()
            }
        }
        triggerSave()
    }

    func loadGame(boards: [MacpardyBoard]) {
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
        self.finalMacpardyWagers = [:]
    }

    func addTeam(name: String = "", color: String = "blue") {
        let count = game.teams.count + 1
        let teamName = name.isEmpty ? String(localized: "team.default_name \(count)") : name
        let availableColors = ["blue", "red", "green", "yellow", "purple", "orange"]
        let chosenColor = availableColors[(count - 1) % availableColors.count]
        game.teams.append(Team(name: teamName, score: 0, color: chosenColor))
        triggerSave()
    }

    func removeTeam(at index: Int) {
        guard game.teams.indices.contains(index) else { return }
        game.teams.remove(at: index)
        triggerSave()
    }

    func removeTeam(id: UUID) {
        game.teams.removeAll(where: { $0.id == id })
        triggerSave()
    }

    func removeTeam(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            if game.teams.indices.contains(index) {
                game.teams.remove(at: index)
            }
        }
        triggerSave()
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

    // MARK: - Persistence Triggers

    func triggerSave() {
        guard phase != .setup else { return }
        let snapshot = GameSnapshot(from: self)
        onSaveTriggered?(snapshot)

        pendingSaveTask?.cancel()
        pendingSaveTask = Task { [snapshot] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            try? await GameSaveStore.shared.save(snapshot)
        }
    }
}
