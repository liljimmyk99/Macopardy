//
//  ControlQuestionTile.swift
//  Macpardy
//
//  One clickable board tile. Played tiles go blank and disabled, as on the Display.
//

import SwiftUI

struct ControlQuestionTile: View {

    let question: Question
    let categoryTitle: String
    let action: () -> Void

    @State private var isHovered = false

    private var fill: Color {
        if question.hasBeenPlayed { return MacpardyTheme.tilePlayed }
        return isHovered ? MacpardyTheme.tileHover : MacpardyTheme.tileBlue
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(fill)

                if !question.hasBeenPlayed {
                    QuestionValueView(value: question.value, font: MacpardyTheme.controlValueFont)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 6)
                }
            }
            .overlay(alignment: .topTrailing) {
                if question.isDailyDouble && !question.hasBeenPlayed {
                    Text("control.board.tile.daily_double")
                        .font(MacpardyTheme.badgeFont)
                        .foregroundStyle(MacpardyTheme.boardBlue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(MacpardyTheme.gold, in: RoundedRectangle(cornerRadius: 4))
                        .padding(6)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if question.image != nil && !question.hasBeenPlayed {
                    Image(systemName: "photo")
                        .font(.caption)
                        .foregroundStyle(MacpardyTheme.mutedText)
                        .padding(8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(question.hasBeenPlayed)
        .onHover { isHovered = $0 }
        .accessibilityLabel(Text("control.board.tile.accessibility \(categoryTitle) \(question.value)"))
        .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: Text {
        if question.hasBeenPlayed { return Text("control.board.tile.played") }
        if question.isDailyDouble { return Text("control.board.tile.daily_double.accessibility") }
        return Text(verbatim: "")
    }
}

#Preview {
    HStack(spacing: 4) {
        ControlQuestionTile(question: Question(value: 400, clue: "Test", response: "Test"), categoryTitle: "Science") {}
        ControlQuestionTile(
            question: Question(value: 800, clue: "Test", response: "Test", isDailyDouble: true),
            categoryTitle: "Science"
        ) {}
        ControlQuestionTile(
            question: Question(value: 400, clue: "Test", response: "Test", hasBeenPlayed: true),
            categoryTitle: "Science"
        ) {}
    }
    .frame(width: 480, height: 110)
    .padding()
    .background(MacpardyTheme.boardBlue)
}
