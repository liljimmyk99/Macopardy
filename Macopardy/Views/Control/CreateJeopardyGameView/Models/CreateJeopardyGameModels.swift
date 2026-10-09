//
//  CreateJeopardyGameModels.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import Foundation

struct DraftCategory: Identifiable {

    let id = UUID()
    let title: String
    var questions: [DraftQuestion]
}

struct DraftQuestion {

    let value: Int
    var clue: String
    var response: String

    var isComplete: Bool {
        !clue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct EditingQuestion: Identifiable {

    let id = UUID()
    let categoryIndex: Int
    let questionIndex: Int
    let value: Int
    let clue: String
    let response: String
}

struct DraftFinalJeopardy {

    var category: String = ""
    var clue: String = ""
    var response: String = ""

    var isComplete: Bool {
        !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !clue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
