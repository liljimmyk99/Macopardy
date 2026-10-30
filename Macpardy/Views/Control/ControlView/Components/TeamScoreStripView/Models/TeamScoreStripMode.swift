//
//  TeamScoreStripMode.swift
//  Macpardy
//
//  Which buttons the team score strip shows for the current phase.
//

import Foundation

enum TeamScoreStripMode: Equatable {
    /// Scores only.
    case readOnly
    /// ±100 manual adjustments (board phase).
    case manual
    /// Wrong / correct for a clue worth `amount`. On a Daily Double only that
    /// team can score, and scoring doesn't touch the buzzers.
    case clue(amount: Int, dailyDoubleTeamID: UUID?)
}
