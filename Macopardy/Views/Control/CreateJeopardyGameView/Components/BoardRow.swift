//
//  BoardRow.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import SwiftUI

struct BoardRow: View {
    @Binding var draftCategories: [DraftCategory]
    @Binding var selectedQuestion: EditingQuestion?
    var rowIndex: Int
    var value: Int

    var body: some View {
        ForEach(Array(draftCategories.enumerated()), id: \.element.id) { categoryIndex, category in
            let question = category.questions[rowIndex]
            QuestionTileButtonView(
                value: value,
                isComplete: question.isComplete,
                action: {
                    selectedQuestion = EditingQuestion(
                        categoryIndex: categoryIndex,
                        questionIndex: rowIndex,
                        value: value,
                        clue: question.clue,
                        response: question.response
                    )
                }
            )
            .frame(width: 180, height: 120)
            .accessibilityLabel("\(category.title) question for \(value), \(question.isComplete ? "completed" : "incomplete")")
        }
    }
}
