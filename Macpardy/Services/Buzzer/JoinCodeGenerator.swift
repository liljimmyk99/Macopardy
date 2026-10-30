//
//  JoinCodeGenerator.swift
//  Macpardy
//
//  Generates a cryptographically random 6-character join code.
//  Characters that are visually ambiguous (0/O, 1/I/l) are excluded.
//

import Foundation

enum JoinCodeGenerator {
    private static let alphabet = Array("ABCDEFGHJKMNPQRSTUVWXYZ23456789")

    /// Returns a new 6-character join code composed of unambiguous uppercase
    /// letters and digits.
    static func generate() -> String {
        (0..<6).map { _ in alphabet[Int.random(in: alphabet.indices)] }
            .reduce(into: "") { $0.append($1) }
    }
}
