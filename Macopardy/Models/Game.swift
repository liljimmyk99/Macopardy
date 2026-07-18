//
//  Game.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

struct Game {

    var rounds: [JeopardyBoard]

    var currentRound: Int = 0

    var teams: [Team]

    var currentBoard: JeopardyBoard? {
        guard currentRound >= 0, currentRound < rounds.count else { return nil }
        return rounds[currentRound]
    }
}
