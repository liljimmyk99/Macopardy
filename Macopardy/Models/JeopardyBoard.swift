//
//  JeopardyBoard.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//
import Foundation

struct JeopardyBoard: Identifiable, Codable {

    let id: UUID
    var title: String

    var round: JeopardyRound

    var categories: [Category]

    init(
        id: UUID = UUID(),
        title: String,
        round: JeopardyRound,
        categories: [Category]
    ) {
        self.id = id
        self.title = title
        self.round = round
        self.categories = categories
    }
}

// For testing
extension JeopardyBoard {

    static let sample = JeopardyBoard(
        title: "Round 1",
        round: .jeopardy,
        categories: [
            Category(
                title: "Science",
                questions: [
                    Question(value: 200,
                             clue: "The closest star to Earth.",
                             response: "What is the Sun?"),

                    Question(value: 400,
                             clue: "This planet has the Great Red Spot.",
                             response: "What is Jupiter?"),

                    Question(value: 600,
                             clue: "...",
                             response: "..."),

                    Question(value: 800,
                             clue: "...",
                             response: "..."),

                    Question(value: 1000,
                             clue: "...",
                             response: "...")
                ]
            )
        ]
    )
}
