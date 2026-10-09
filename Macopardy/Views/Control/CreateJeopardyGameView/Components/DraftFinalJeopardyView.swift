//
//  DraftFinalJeopardyView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/8/26.
//

import SwiftUI

struct DraftFinalJeopardyView: View {

    @Binding var draft: DraftFinalJeopardy

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.headline)
                    .foregroundStyle(.primary)

                TextField("Enter Final Jeopardy Category (e.g. American History)", text: $draft.category)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 480)
                    .accessibilityLabel("Final Jeopardy Category")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Question / Clue")
                    .font(.headline)
                    .foregroundStyle(.primary)

                MultilineTextEditor(
                    text: $draft.clue,
                    placeholder: "Enter the Final Jeopardy clue or question..."
                )
                .frame(minHeight: 140)
                .accessibilityLabel("Final Jeopardy Clue")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Answer / Response")
                    .font(.headline)
                    .foregroundStyle(.primary)

                MultilineTextEditor(
                    text: $draft.response,
                    placeholder: "Enter the correct response (e.g. What is the Constitution?)..."
                )
                .frame(minHeight: 140)
                .accessibilityLabel("Final Jeopardy Response")
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
    }
}
