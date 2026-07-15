//
//  Team.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//
import Foundation

struct Team: Identifiable {

    let id = UUID()

    var name: String

    var score: Int

    var color: String
}
