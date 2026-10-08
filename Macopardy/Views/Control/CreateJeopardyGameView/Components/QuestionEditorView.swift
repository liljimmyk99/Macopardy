//
//  QuestionEditorView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import SwiftUI

struct QuestionEditorView: View {

    let value: Int

    @Binding
    var clue: String

    @Binding
    var response: String

    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("$\(value)")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("Done") {
                    onDone()
                }
                .buttonStyle(.borderedProminent)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Question / Clue")
                    .font(.headline)

                MultilineTextEditor(text: $clue, placeholder: "Enter the clue or question...")
                    .frame(minHeight: 120)
                    .accessibilityLabel("Question clue for \(value)")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Answer / Response")
                    .font(.headline)

                MultilineTextEditor(text: $response, placeholder: "Enter the answer or response...")
                    .frame(minHeight: 120)
                    .accessibilityLabel("Answer response for \(value)")
            }
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 360)
    }
}
