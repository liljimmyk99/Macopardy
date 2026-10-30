import SwiftUI

extension BoardView {
    var shouldPlayIntro: Bool {
        gameState.boardIntroPending && animationsEnabled
    }

    var reveal: BoardReveal {
        introReveal ?? (shouldPlayIntro ? .hidden : .complete)
    }

    /// Categories appear one at a time, then every clue tile turns over.
    func playIntro() async {
        guard introReveal == nil, shouldPlayIntro else { return }
        introReveal = .hidden
        do {
            for index in board.categories.indices {
                try await Task.sleep(for: MacpardyMotion.categoryInterval)
                introReveal?.categoriesShown = index + 1
            }
            try await Task.sleep(for: MacpardyMotion.pauseBeforeClues)
            introReveal?.cluesShown = true
            try await Task.sleep(for: .seconds(1))
        } catch {
            return
        }
        introReveal = .complete
        gameState.boardIntroPending = false
    }
}
