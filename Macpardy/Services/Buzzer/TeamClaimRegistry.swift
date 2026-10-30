//
//  TeamClaimRegistry.swift
//  Macpardy
//
//  Tracks which phone session currently holds each team. A team is held by at
//  most one session; a claim lives exactly as long as its session does.
//  Scores are never stored here, so a freed team keeps its score.
//

import Foundation

nonisolated struct TeamClaimRegistry {

    enum ClaimResult: Equatable {
        case claimed
        case alreadyHeld
        case taken
        case invalidTeam
    }

    private(set) var claims: [UUID: UUID] = [:]   // team id -> session id

    var claimedTeamIDs: Set<UUID> { Set(claims.keys) }

    func isClaimed(_ teamID: UUID) -> Bool {
        claims[teamID] != nil
    }

    func teamID(for sessionID: UUID) -> UUID? {
        claims.first { $0.value == sessionID }?.key
    }

    func sessionID(for teamID: UUID) -> UUID? {
        claims[teamID]
    }

    /// Claims `teamID` for `sessionID`. A session holds at most one team, so any
    /// team it previously held is released when the new claim succeeds.
    mutating func claim(teamID: UUID, sessionID: UUID, validTeamIDs: Set<UUID>) -> ClaimResult {
        guard validTeamIDs.contains(teamID) else { return .invalidTeam }
        if let holder = claims[teamID] {
            return holder == sessionID ? .alreadyHeld : .taken
        }
        release(sessionID: sessionID)
        claims[teamID] = sessionID
        return .claimed
    }

    /// Frees whatever team the session holds. Returns that team's id, if any.
    @discardableResult
    mutating func release(sessionID: UUID) -> UUID? {
        guard let teamID = teamID(for: sessionID) else { return nil }
        claims.removeValue(forKey: teamID)
        return teamID
    }

    /// Frees the team regardless of who holds it. Returns the previous holder.
    @discardableResult
    mutating func remove(teamID: UUID) -> UUID? {
        claims.removeValue(forKey: teamID)
    }

    /// Drops claims on teams that no longer exist. Returns the evicted sessions.
    @discardableResult
    mutating func prune(validTeamIDs: Set<UUID>) -> [UUID] {
        let stale = claims.keys.filter { !validTeamIDs.contains($0) }
        return stale.compactMap { claims.removeValue(forKey: $0) }
    }

    /// Frees every claim whose session is not in `liveSessionIDs` (TTL sweep).
    /// Returns the freed team ids.
    @discardableResult
    mutating func sweep(liveSessionIDs: Set<UUID>) -> [UUID] {
        let dead = claims.filter { !liveSessionIDs.contains($0.value) }.map(\.key)
        dead.forEach { claims.removeValue(forKey: $0) }
        return dead
    }
}
