//
//  QuestionPickerView.swift
//  Macopardy
//

import SwiftUI

struct QuestionPickerView: View {

    @Environment(GameState.self) var gameState

    var body: some View {
        GroupBox("Question Picker") {
            questionPickerContent()
        }
    }
}

#Preview {
    QuestionPickerView()
        .environment(GameState())
        .padding()
        .frame(width: 600)
}
