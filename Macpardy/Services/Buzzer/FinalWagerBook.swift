//
//  FinalWagerBook.swift
//  Macpardy
//
//  Validation and storage for Final Macpardy wagers submitted from phones.
//  It has no networking: the server feeds it submissions and reads back what
//  each phone should show. The game state stays the source of truth; this
//  book is re-seeded from it whenever wagering opens.
//

import Foundation

/// What a phone's wager screen shows.
nonisolated struct WagerInfo: Equatable {
    /// False for teams that can't win points (score of zero or less).
    let eligible: Bool
    let max: Int
    /// The locked-in wager, if one was submitted or entered by the host.
    let wager: Int?
}

/// A wager a phone submitted, handed to the app to store.
nonisolated struct WagerSubmission: Equatable {
    let teamID: UUID
    let amount: Int
}

/// Why a submitted wager was refused.
nonisolated enum WagerRejectReason: String, Encodable, Equatable {
    case notOpen
    case notEligible
    case locked
    case negative
    case overMax
}

nonisolated struct FinalWagerBook {

    enum SubmitResult: Equatable {
        case accepted(Int)
        case rejected(WagerRejectReason)
    }

    /// Max wager per team (its score). Nil while wagering is closed.
    private var limits: [UUID: Int]?
    private var wagers: [UUID: Int] = [:]

    var isOpen: Bool { limits != nil }

    // MARK: - Host-driven transitions

    mutating func open(limits: [UUID: Int], wagers: [UUID: Int]) {
        self.limits = limits
        self.wagers = wagers.filter { (limits[$0.key] ?? 0) > 0 }
    }

    mutating func close() {
        limits = nil
        wagers = [:]
    }

    /// Stores a wager entered by the host, clamped to the team's limit.
    /// Returns the stored value, or nil if the team can't wager.
    @discardableResult
    mutating func hostSet(teamID: UUID, amount: Int) -> Int? {
        guard let max = limits?[teamID], max > 0 else { return nil }
        let clamped = Swift.min(Swift.max(0, amount), max)
        wagers[teamID] = clamped
        return clamped
    }

    /// Forgets a team's wager (the host cleared it), so it defaults to all-in.
    mutating func hostClear(teamID: UUID) {
        wagers[teamID] = nil
    }

    // MARK: - Phone input

    /// Only the first submission counts; after that only the host can edit.
    mutating func submit(teamID: UUID, amount: Int) -> SubmitResult {
        guard let limits else { return .rejected(.notOpen) }
        guard let max = limits[teamID], max > 0 else { return .rejected(.notEligible) }
        guard wagers[teamID] == nil else { return .rejected(.locked) }
        guard amount >= 0 else { return .rejected(.negative) }
        guard amount <= max else { return .rejected(.overMax) }
        wagers[teamID] = amount
        return .accepted(amount)
    }

    // MARK: - Phone display

    func info(for teamID: UUID) -> WagerInfo? {
        guard let limits else { return nil }
        let max = limits[teamID] ?? 0
        return WagerInfo(eligible: max > 0, max: Swift.max(0, max), wager: wagers[teamID])
    }
}
