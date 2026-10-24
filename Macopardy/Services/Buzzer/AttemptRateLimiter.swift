//
//  AttemptRateLimiter.swift
//  Macopardy
//
//  Sliding-window attempt counter with a lockout, keyed by remote address.
//  Pure value type; the caller supplies the clock so it can be tested.
//

import Foundation

nonisolated struct AttemptRateLimiter {

    let maxAttempts: Int
    let window: TimeInterval
    let lockout: TimeInterval

    private var attempts: [String: [Date]] = [:]
    private var lockedUntil: [String: Date] = [:]

    init(maxAttempts: Int, window: TimeInterval, lockout: TimeInterval) {
        self.maxAttempts = maxAttempts
        self.window = window
        self.lockout = lockout
    }

    /// Whether `key` may make another attempt right now.
    func isBlocked(_ key: String, now: Date = Date()) -> Bool {
        guard let until = lockedUntil[key] else { return false }
        return now < until
    }

    /// Records an attempt. Returns `true` if the key is (now) rate limited.
    @discardableResult
    mutating func record(_ key: String, now: Date = Date()) -> Bool {
        if isBlocked(key, now: now) { return true }
        lockedUntil.removeValue(forKey: key)

        var recent = (attempts[key] ?? []).filter { now.timeIntervalSince($0) < window }
        recent.append(now)
        attempts[key] = recent

        if recent.count > maxAttempts {
            lockedUntil[key] = now.addingTimeInterval(lockout)
            attempts.removeValue(forKey: key)
            return true
        }
        return false
    }

    /// Forgets expired entries so the dictionaries don't grow without bound.
    mutating func prune(now: Date = Date()) {
        lockedUntil = lockedUntil.filter { now < $0.value }
        attempts = attempts.compactMapValues { dates in
            let recent = dates.filter { now.timeIntervalSince($0) < window }
            return recent.isEmpty ? nil : recent
        }
    }
}
