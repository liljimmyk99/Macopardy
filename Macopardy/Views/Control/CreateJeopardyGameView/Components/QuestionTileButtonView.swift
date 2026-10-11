//
//  QuestionTileButtonView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import SwiftUI

struct QuestionTileButtonView: View {

    let value: Int
    let isComplete: Bool
    var isDailyDouble: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(JeopardyTheme.tileBlue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isComplete ? JeopardyTheme.gold : Color.clear, lineWidth: 2)
                    )

                HStack(spacing: 4) {
                    if isDailyDouble {
                        Image(systemName: "star.fill")
                            .foregroundStyle(JeopardyTheme.gold)
                            .font(.caption)
                    }
                    if isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(JeopardyTheme.gold)
                    }
                }
                .padding(8)

                QuestionValueView(value: value)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isComplete ? [.isButton, .isSelected] : [.isButton])
        .accessibilityHint(isComplete ? "Completed question, edit to update" : "Incomplete question, edit to complete")
    }
}
