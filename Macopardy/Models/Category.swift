//
//  Category.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//
import Foundation

struct Category: Identifiable, Codable {

    let id: UUID

    var title: String

    var questions: [Question]

    init(
        id: UUID = UUID(),
        title: String,
        questions: [Question]
    ) {
        self.id = id
        self.title = title
        self.questions = questions
    }
}
