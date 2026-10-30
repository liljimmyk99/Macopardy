//
//  GameSnapshot.swift
//  Macpardy
//
//  Created by Jimmy Kane on 10/18/26.
//

import Foundation

struct GameSnapshot: Codable, Equatable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let savedAt: Date
    let game: Game
    let phase: GamePhase
    let currentQuestionID: UUID?
    let currentCategoryTitle: String?
    let dailyDoubleTeamID: UUID?
    let dailyDoubleWager: Int
    let finalMacpardyWagers: [UUID: Int]

    init(
        schemaVersion: Int = GameSnapshot.currentSchemaVersion,
        savedAt: Date = Date(),
        game: Game,
        phase: GamePhase,
        currentQuestionID: UUID? = nil,
        currentCategoryTitle: String? = nil,
        dailyDoubleTeamID: UUID? = nil,
        dailyDoubleWager: Int = 0,
        finalMacpardyWagers: [UUID: Int] = [:]
    ) {
        self.schemaVersion = schemaVersion
        self.savedAt = savedAt
        self.game = game
        self.phase = phase
        self.currentQuestionID = currentQuestionID
        self.currentCategoryTitle = currentCategoryTitle
        self.dailyDoubleTeamID = dailyDoubleTeamID
        self.dailyDoubleWager = dailyDoubleWager
        self.finalMacpardyWagers = finalMacpardyWagers
    }

    init(from gameState: GameState) {
        self.schemaVersion = Self.currentSchemaVersion
        self.savedAt = Date()
        self.game = gameState.game
        self.phase = gameState.phase
        self.currentQuestionID = gameState.currentQuestion?.id
        self.currentCategoryTitle = gameState.currentCategoryTitle
        self.dailyDoubleTeamID = gameState.dailyDoubleTeamID
        self.dailyDoubleWager = gameState.dailyDoubleWager
        self.finalMacpardyWagers = gameState.finalMacpardyWagers
    }
}
