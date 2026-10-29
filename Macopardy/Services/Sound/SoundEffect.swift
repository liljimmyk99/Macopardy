//
//  SoundEffect.swift
//  Macopardy
//

import Foundation

/// A sound the app can play. Raw values are the file names in `Resources/Sounds`.
enum SoundEffect: String, CaseIterable {
    case incorrect
    case timerWarning = "timer_warning"
    case dailyDouble = "daily_double"
    case finalMacpardy = "final_macpardy"
    case backgroundMusic = "background_music"

    var fileExtension: String { "wav" }

    /// Music is controlled separately from the effects, loops, and plays quieter.
    var isMusic: Bool { self == .backgroundMusic }

    var volume: Float { isMusic ? 0.25 : 1.0 }
}

/// What the sound should do when the game enters a phase.
struct SoundCue: Equatable {
    /// Plays once, if any.
    var effect: SoundEffect?
    /// Whether the background music should be playing in this phase.
    var playsMusic: Bool

    static func entering(_ phase: GamePhase) -> SoundCue {
        switch phase {
        case .board: SoundCue(effect: nil, playsMusic: true)
        case .dailyDouble: SoundCue(effect: .dailyDouble, playsMusic: false)
        case .finalMacpardyCategory: SoundCue(effect: .finalMacpardy, playsMusic: false)
        case .setup, .question, .answer, .finalMacpardyQuestion, .finalMacpardyAnswer:
            SoundCue(effect: nil, playsMusic: false)
        }
    }
}
