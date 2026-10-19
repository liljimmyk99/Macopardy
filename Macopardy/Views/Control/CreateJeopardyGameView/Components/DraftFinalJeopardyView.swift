//
//  DraftFinalJeopardyView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/8/26.
//

import SwiftUI

struct DraftFinalJeopardyView: View {
    @FocusState private var focusedField: Field?
    @Binding var draft: DraftFinalJeopardy
    
    private enum Field: Hashable {
        case category
        case question
        case answer
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("create.final_jeopardy.category_label")
                    .font(.headline)
                    .foregroundStyle(.primary)

                TextField("create.final_jeopardy.category_placeholder", text: $draft.category)
                    .focused($focusedField, equals: .category)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 480)
                    .accessibilityLabel(Text("create.final_jeopardy.category_accessibility"))
                    .onSubmit {
                        focusedField = .question
                    }
                    .onKeyPress(phases: .down) { press in
                        if press.key == .tab {
                            if press.modifiers.contains(.shift) {
                                focusedField = .answer
                            } else {
                                focusedField = .question
                            }
                            return .handled
                        }
                        return .ignored
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("create.question.clue_label")
                    .font(.headline)
                    .foregroundStyle(.primary)

                MultilineTextEditor(
                    text: $draft.clue,
                    placeholder: String(localized: "create.final_jeopardy.clue_placeholder"),
                    minHeight: 140
                )
                .focused($focusedField, equals: .question)
                .accessibilityLabel(Text("create.final_jeopardy.clue_accessibility"))
                .onSubmit {
                    focusedField = .answer
                }
                .onKeyPress(phases: .down) { press in
                    if press.key == .tab {
                        if press.modifiers.contains(.shift) {
                            focusedField = .category
                        } else {
                            focusedField = .answer
                        }
                        return .handled
                    }
                    return .ignored
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("create.question.response_label")
                    .font(.headline)
                    .foregroundStyle(.primary)

                MultilineTextEditor(
                    text: $draft.response,
                    placeholder: String(localized: "create.final_jeopardy.response_placeholder"),
                    minHeight: 140
                )
                .focused($focusedField, equals: .answer)
                .accessibilityLabel(Text("create.final_jeopardy.response_accessibility"))
                .onSubmit {
                    focusedField = .category
                }
                .onKeyPress(phases: .down) { press in
                    if press.key == .tab {
                        if press.modifiers.contains(.shift) {
                            focusedField = .question
                        } else {
                            focusedField = .category
                        }
                        return .handled
                    }
                    return .ignored
                }
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(JeopardyTheme.boardBlue.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(JeopardyTheme.gold.opacity(0.4), lineWidth: 1.5)
        )
        .onAppear {
            focusedField = .category
        }
    }
}
