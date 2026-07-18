//
//  Team.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//
import Foundation
import SwiftUI

struct Team: Identifiable {

    let id = UUID()

    var name: String

    var score: Int

    var color: String

    var displayColor: Color {
        switch color.lowercased() {
        case "blue": Color(red: 0.2, green: 0.45, blue: 0.95)
        case "red": Color(red: 0.9, green: 0.25, blue: 0.25)
        case "green": Color(red: 0.2, green: 0.75, blue: 0.35)
        case "yellow": Color(red: 0.95, green: 0.85, blue: 0.2)
        case "purple": Color(red: 0.6, green: 0.3, blue: 0.85)
        case "orange": Color(red: 0.95, green: 0.55, blue: 0.15)
        default: .gray
        }
    }
}

extension Team {

    static let sampleTeams: [Team] = [
        Team(name: "Blue Team", score: 2400, color: "blue"),
        Team(name: "Red Team", score: 1800, color: "red"),
        Team(name: "Green Team", score: 600, color: "green"),
    ]
}
