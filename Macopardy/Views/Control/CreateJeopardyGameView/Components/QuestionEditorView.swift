//
//  QuestionEditorView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import SwiftUI

struct QuestionEditorView: View {
    @FocusState private var focusedField: Field?

    let value: Int

    @Binding
    var clue: String

    @Binding
    var response: String

    let onDone: () -> Void

    private enum Field: Hashable {
        case clue
        case response
    }

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
                    .focused($focusedField, equals: .clue)
                    .accessibilityLabel("Question clue for \(value)")
                    .onSubmit {
                        focusedField = .response
                    }
                    .onKeyPress(phases: .down) { press in
                        if press.key == .tab {
                            focusedField = .response
                            return .handled
                        }
                        return .ignored
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Answer / Response")
                    .font(.headline)

                MultilineTextEditor(text: $response, placeholder: "Enter the answer or response...")
                    .focused($focusedField, equals: .response)
                    .accessibilityLabel("Answer response for \(value)")
                    .onSubmit {
                        onDone()
                    }
                    .onKeyPress(phases: .down) { press in
                        if press.key == .tab {
                            if press.modifiers.contains(.shift) {
                                focusedField = .clue
                            } else {
                                focusedField = .clue
                            }
                            return .handled
                        }
                        return .ignored
                    }
            }
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 360)
        .onAppear {
            focusedField = .clue
        }
    }
}
