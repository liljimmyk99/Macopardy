//
//  BuzzTieResolver.swift
//  Macpardy
//
//  Picks the winner among buzzes received inside the tie window. Kept separate
//  from the engine so the tie rules can be tweaked on their own.
//

import Foundation

/// One buzz as received by the server.
nonisolated struct Buzz: Equatable {
    let teamID: UUID
    let receivedAt: Date
    let score: Int
}

nonisolated enum BuzzTieResolver {

    /// The lowest score wins; teams with equal scores are picked at random.
    /// `randomIndex` receives the number of tied teams and returns an index into
    /// them, so tests can make the random pick deterministic.
    static func winner(
        of buzzes: [Buzz],
        randomIndex: (Int) -> Int = { Int.random(in: 0..<$0) }
    ) -> Buzz? {
        guard let lowest = buzzes.map(\.score).min() else { return nil }
        let tied = buzzes.filter { $0.score == lowest }
        return tied[randomIndex(tied.count)]
    }
}
