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
                Text("Category")
                    .font(.headline)
                    .foregroundStyle(.primary)

                TextField("Enter Final Jeopardy Category (e.g. American History)", text: $draft.category)
                    .focused($focusedField, equals: .category)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 480)
                    .accessibilityLabel("Final Jeopardy Category")
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
                Text("Question / Clue")
                    .font(.headline)
                    .foregroundStyle(.primary)

                MultilineTextEditor(
                    text: $draft.clue,
                    placeholder: "Enter the Final Jeopardy clue or question...",
                    minHeight: 140
                )
                .focused($focusedField, equals: .question)
                .accessibilityLabel("Final Jeopardy Clue")
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
                Text("Answer / Response")
                    .font(.headline)
                    .foregroundStyle(.primary)

                MultilineTextEditor(
                    text: $draft.response,
                    placeholder: "Enter the correct response (e.g. What is the Constitution?)...",
                    minHeight: 140
                )
                .focused($focusedField, equals: .answer)
                .accessibilityLabel("Final Jeopardy Response")
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
