//
//  Team.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//
import Foundation
import SwiftUI

struct Team: Identifiable, Equatable, Codable {

    /// Most teams a game can have; each can be claimed by one buzzer phone.
    static let maxCount = 4

    let id: UUID
    var name: String
    var score: Int
    var color: String

    init(id: UUID = UUID(), name: String, score: Int = 0, color: String = "blue") {
        self.id = id
        self.name = name
        self.score = score
        self.color = color
    }

    /// Color names a team can pick, in picker order.
    static let colorOptions = ["blue", "red", "green", "yellow", "purple", "orange"]

    var displayColor: Color {
        Team.displayColor(for: color)
    }

    static func displayColor(for color: String) -> Color {
        switch color.lowercased() {
        case "blue": MacopardyAsset.teamBlue.swiftUIColor
        case "red": MacopardyAsset.teamRed.swiftUIColor
        case "green": MacopardyAsset.teamGreen.swiftUIColor
        case "yellow": MacopardyAsset.teamYellow.swiftUIColor
        case "purple": MacopardyAsset.teamPurple.swiftUIColor
        case "orange": MacopardyAsset.teamOrange.swiftUIColor
        default: .gray
        }
    }
}

extension Team {

    /// Colors given to new teams, in order.
    static let defaultColors = ["blue", "red", "green", "yellow"]

    /// The starting teams, using the count and names from Settings.
    static var defaultNewTeams: [Team] {
        let count = AppSettings.defaultTeamCount()
        return (0..<count).map { index in
            Team(
                name: AppSettings.customTeamName(at: index) ?? String(localized: "team.default_name \(index + 1)"),
                score: 0,
                color: defaultColors[index]
            )
        }
    }

    static let sampleTeams: [Team] = [
        Team(name: "Blue Team", score: 2400, color: "blue"),
        Team(name: "Red Team", score: 1800, color: "red"),
        Team(name: "Green Team", score: 600, color: "green"),
    ]
}
