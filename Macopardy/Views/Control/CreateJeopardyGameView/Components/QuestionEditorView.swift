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

    @Binding
    var isDailyDouble: Bool

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
                Toggle(isOn: $isDailyDouble) {
                    Label("create.question.daily_double", systemImage: "star.fill")
                }
                .toggleStyle(.button)
                .tint(JeopardyTheme.gold)
                Button("common.done") {
                    onDone()
                }
                .buttonStyle(.borderedProminent)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("create.question.clue_label")
                    .font(.headline)

                MultilineTextEditor(text: $clue, placeholder: String(localized: "create.question.clue_placeholder"))
                    .focused($focusedField, equals: .clue)
                    .accessibilityLabel(Text("create.question.clue_accessibility \(value)"))
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
                Text("create.question.response_label")
                    .font(.headline)

                MultilineTextEditor(text: $response, placeholder: String(localized: "create.question.response_placeholder"))
                    .focused($focusedField, equals: .response)
                    .accessibilityLabel(Text("create.question.response_accessibility \(value)"))
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
