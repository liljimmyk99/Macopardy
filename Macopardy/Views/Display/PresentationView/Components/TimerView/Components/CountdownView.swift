//
//  CountdownView.swift
//  Macopardy
//

import SwiftUI

struct CountdownView: View {

    let seconds: Int
    var font: Font = MacpardyTheme.timerFont
    var color: Color = MacpardyTheme.gold

    var body: some View {
        countdownText()
    }
}

#Preview {
    CountdownView(seconds: 30)
        .padding()
        .background(MacpardyTheme.clueBackground)
}
