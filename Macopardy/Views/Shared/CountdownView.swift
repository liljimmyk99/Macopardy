//
//  CountdownView.swift
//  Macopardy
//

import SwiftUI

struct CountdownView: View {

    let seconds: Int
    var font: Font = JeopardyTheme.timerFont
    var color: Color = JeopardyTheme.gold

    var body: some View {
        Text("\(seconds)")
            .font(font)
            .foregroundStyle(color)
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.default, value: seconds)
    }
}

#Preview {
    CountdownView(seconds: 30)
        .padding()
        .background(JeopardyTheme.clueBackground)
}
