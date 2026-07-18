//
//  QuestionPickerView.swift
//  Macopardy
//

import SwiftUI

struct QuestionPickerView: View {

    @Environment(GameState.self) private var gameState

    var body: some View {
        GroupBox("Question Picker") {
            if let board = gameState.game.currentBoard {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(board.categories) { category in
                            categorySection(category)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 400)
            } else {
                Text("No board available")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func categorySection(_ category: Category) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.title)
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                ForEach(category.questions) { question in
                    questionButton(question, categoryTitle: category.title)
                }
            }
        }
    }

    private func questionButton(_ question: Question, categoryTitle: String) -> some View {
        Button {
            gameState.selectQuestion(question, categoryTitle: categoryTitle)
        } label: {
            VStack(spacing: 4) {
                Text("$\(question.value)")
                    .fontWeight(.bold)

                if question.hasBeenPlayed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.secondary)
                } else if question.isDailyDouble {
                    Text("DD")
                        .font(.caption2.bold())
                        .foregroundStyle(JeopardyTheme.gold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
        .disabled(question.hasBeenPlayed)
    }
}

#Preview {
    QuestionPickerView()
        .environment(GameState())
        .padding()
        .frame(width: 600)
}
