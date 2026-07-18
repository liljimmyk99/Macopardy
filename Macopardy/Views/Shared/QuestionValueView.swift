//
//  QuestionValueView.swift
//  Macopardy
//

import SwiftUI

struct QuestionValueView: View {

    let value: Int
    var font: Font = JeopardyTheme.valueFont

    var body: some View {
        Text("$\(value)")
            .font(font)
            .foregroundStyle(JeopardyTheme.gold)
    }
}

#Preview {
    QuestionValueView(value: 400)
        .padding()
        .background(JeopardyTheme.tileBlue)
}
