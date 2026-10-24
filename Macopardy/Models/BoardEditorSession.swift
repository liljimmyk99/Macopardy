//
//  BoardEditorSession.swift
//  Macopardy
//

import Foundation
import Observation

/// Passes work between the launch screen, the editor window, and the app:
/// a loaded board to edit, and an edited board the user wants to play.
@Observable
final class BoardEditorSession {

    /// A loaded board waiting for the editor to pick it up.
    private(set) var pendingDraft: BoardDraft?

    /// Goes up on every `edit(_:)` so an editor that's already open reloads.
    private(set) var editRequest = 0

    /// Boards the user chose to play after saving an edit. The app starts
    /// the game and clears this.
    var boardsToPlay: [MacpardyBoard]?

    /// Queues `draft` for the editor.
    func edit(_ draft: BoardDraft) {
        pendingDraft = draft
        editRequest += 1
    }

    /// Hands the queued draft to the editor, once.
    func takePendingDraft() -> BoardDraft? {
        defer { pendingDraft = nil }
        return pendingDraft
    }
}
