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
            makeCategory("Science", clues: [
                "The closest star to Earth.",
                "This planet has the Great Red Spot.",
                "The force that keeps planets in orbit.",
                "This element has the symbol Au.",
                "The study of living organisms.",
            ], responses: [
                "What is the Sun?",
                "What is Jupiter?",
                "What is gravity?",
                "What is gold?",
                "What is biology?",
            ]),
            makeCategory("History", clues: [
                "This 1776 document declared American independence.",
                "The ancient Egyptian writing system.",
                "This wall divided Berlin from 1961 to 1989.",
                "The first president of the United States.",
                "This empire was ruled from Rome.",
            ], responses: [
                "What is the Declaration of Independence?",
                "What are hieroglyphics?",
                "What is the Berlin Wall?",
                "Who is George Washington?",
                "What is the Roman Empire?",
            ]),
            makeCategory("Literature", clues: [
                "Shakespeare's star-crossed lovers from Verona.",
                "The author of \"1984\".",
                "This detective lives at 221B Baker Street.",
                "The author of \"Pride and Prejudice\".",
                "This epic poem tells of Odysseus's journey home.",
            ], responses: [
                "Who are Romeo and Juliet?",
                "Who is George Orwell?",
                "Who is Sherlock Holmes?",
                "Who is Jane Austen?",
                "What is the Odyssey?",
            ]),
            makeCategory("Geography", clues: [
                "The longest river in the world.",
                "The capital of France.",
                "This mountain range separates Europe and Asia.",
                "The largest ocean on Earth.",
                "This country is both a continent and a nation.",
            ], responses: [
                "What is the Nile?",
                "What is Paris?",
                "What are the Urals?",
                "What is the Pacific?",
                "What is Australia?",
            ]),
            makeCategory("Pop Culture", clues: [
                "This 1997 film featured Jack and Rose on the Titanic.",
                "The streaming service known for \"Stranger Things\".",
                "This singer performed \"Shake It Off\".",
                "The wizarding school Harry Potter attends.",
                "This franchise features lightsabers and the Force.",
            ], responses: [
                "What is Titanic?",
                "What is Netflix?",
                "Who is Taylor Swift?",
                "What is Hogwarts?",
                "What is Star Wars?",
            ]),
            makeCategory("Think Music", clues: [
                "This instrument has 88 keys.",
                "The Beatles were from this city.",
                "This note follows sol in the scale.",
                "The composer of the \"Moonlight Sonata\".",
                "This genre originated in New Orleans in the early 1900s.",
            ], responses: [
                "What is a piano?",
                "What is Liverpool?",
                "What is la?",
                "Who is Beethoven?",
                "What is jazz?",
            ]),
        ]
    )

    private static func makeCategory(
        _ title: String,
        clues: [String],
        responses: [String]
    ) -> Category {
        let values = [200, 400, 600, 800, 1000]
        let questions = zip(values, zip(clues, responses)).map { value, pair in
            Question(value: value, clue: pair.0, response: pair.1)
        }
        return Category(title: title, questions: questions)
    }
}
