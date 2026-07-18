//
//  DailyDoubleView.swift
//  Macopardy
//

import SwiftUI

struct DailyDoubleView: View {

    var body: some View {
        ZStack {
            JeopardyTheme.clueBackground

            Text("DAILY DOUBLE")
                .font(JeopardyTheme.dailyDoubleFont)
                .foregroundStyle(JeopardyTheme.gold)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DailyDoubleView()
        .frame(width: 960, height: 540)
}
