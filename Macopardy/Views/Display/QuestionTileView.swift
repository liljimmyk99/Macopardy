//
//  QuestionTileView.swift
//  Macopardy
//

import SwiftUI

struct QuestionTileView: View {

    let question: Question

    var body: some View {
        ZStack {
            Rectangle()
                .fill(question.hasBeenPlayed ? JeopardyTheme.tilePlayed : JeopardyTheme.tileBlue)

            if !question.hasBeenPlayed {
                QuestionValueView(value: question.value)
            }
        }
        .aspectRatio(1.4, contentMode: .fit)
    }
}

#Preview {
    HStack {
        QuestionTileView(question: Question(value: 400, clue: "Test", response: "Test"))
        QuestionTileView(
            question: Question(value: 400, clue: "Test", response: "Test", hasBeenPlayed: true)
        )
    }
    .frame(width: 300)
    .padding()
    .background(JeopardyTheme.boardBlue)
}
