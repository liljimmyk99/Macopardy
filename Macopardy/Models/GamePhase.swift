//
//  GamePhase.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//

enum GamePhase: String, CaseIterable {
    case setup = "Setup"
    case board = "Board"
    case question = "Question"
    case answer = "Answer"
    case dailyDouble = "Daily Double"
    case finalJeopardyCategory = "Final Jeopardy Category"
    case finalJeopardyQuestion = "Final Jeopardy Question"
    case finalJeopardyAnswer = "Final Jeopardy Answer"
}
