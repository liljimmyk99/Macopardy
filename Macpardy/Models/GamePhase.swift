//
//  GamePhase.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

enum GamePhase: String, CaseIterable, Codable {
    case setup = "Setup"
    case board = "Board"
    case question = "Question"
    case answer = "Answer"
    case dailyDouble = "Daily Double"
    case finalMacpardyCategory = "Final Macpardy Category"
    case finalMacpardyQuestion = "Final Macpardy Question"
    case finalMacpardyAnswer = "Final Macpardy Answer"
}
