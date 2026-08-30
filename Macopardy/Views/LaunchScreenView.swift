//
//  LaunchScreenView.swift
//  Macopardy
//

import SwiftUI

struct LaunchScreenView: View {

    @Binding var hasSelectedGame: Bool
    let gameState: GameState

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                GameTitleView(title: "Jeopardy!")
                Text("Welcome to Macopardy")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)

            VStack(spacing: 16) {
                LargeButton(
                    title: "Open Existing Game",
                    systemImage: "folder.open"
                ) {
                    hasSelectedGame = true
                }

                LargeButton(
                    title: "New Game",
                    systemImage: "plus.circle",
                    tint: .orange
                ) {
                    // Placeholder for future new game creation flow
                }
            }
            .frame(maxWidth: 300)

            Divider()
                .padding(.vertical, 20)

            VStack(spacing: 12) {
                Text("Quick Preview")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                if let board = gameState.game.currentBoard {
                    BoardPreviewView(board: board)
                        .frame(maxHeight: 300)
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.controlBackgroundColor))
    }
}

struct BoardPreviewView: View {

    let board: JeopardyBoard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(board.title)
                .font(.headline)

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(board.categories, id: \.id) { category in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(category.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(2)

                            VStack(spacing: 4) {
                                ForEach(category.questions, id: \.id) { question in
                                    Text("$\(question.value)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(width: 80)
                        .padding(8)
                        .background(Color(.windowBackgroundColor))
                        .cornerRadius(4)
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    LaunchScreenView(
        hasSelectedGame: .constant(false),
        gameState: GameState()
    )
}
