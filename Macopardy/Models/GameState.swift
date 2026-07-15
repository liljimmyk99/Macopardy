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
    var timer = GameTimer()
    var phase: GamePhase = .board
    
    init(rounds: [JeopardyBoard], currentRound: Int, teams: [Team]) {
        game = Game(
            rounds: rounds,
            currentRound: currentRound,
            teams: teams
        )
    }
}
