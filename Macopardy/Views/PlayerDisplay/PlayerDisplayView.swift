//
//  DisplayView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//
import SwiftUI

struct PlayerDisplayView: View {

    @Environment private var game: GameState

    var body: some View {

        switch game.gamePhase {

        case .board:
            BoardView()

        case .question:
            QuestionView()

        case .answer:
            AnswerView()

        case .finalJeopardy:
            FinalJeopardyView()
        }
    }
}
