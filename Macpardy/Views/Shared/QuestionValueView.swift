//
//  QuestionValueView.swift
//  Macpardy
//

import SwiftUI

struct QuestionValueView: View {

    let value: Int
    var font: Font = MacpardyTheme.valueFont

    var body: some View {
        Text("$\(value)")
            .font(font)
            .foregroundStyle(MacpardyTheme.gold)
    }
}

#Preview {
    QuestionValueView(value: 400)
        .padding()
        .background(MacpardyTheme.tileBlue)
}
