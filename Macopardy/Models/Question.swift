//
//  Question.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//
import Foundation

struct Question: Identifiable, Codable {

    let id: UUID

    let value: Int

    let clue: String

    let response: String

    var hasBeenPlayed: Bool = false

    var isDailyDouble: Bool = false

    init(
        id: UUID = UUID(),
        value: Int,
        clue: String,
        response: String,
        hasBeenPlayed: Bool = false,
        isDailyDouble: Bool = false
    ) {
        self.id = id
        self.value = value
        self.clue = clue
        self.response = response
        self.hasBeenPlayed = hasBeenPlayed
        self.isDailyDouble = isDailyDouble
    }
}
