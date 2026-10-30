//
//  ResponseTimerDots.swift
//  Macopardy
//
//  A row of dots, one per second of response time; a dot goes out each
//  second, left to right. Used on the Display scoreboard and the Control
//  window (issue #59).
//

import SwiftUI

struct ResponseTimerDots: View {

    /// Dots still lit.
    let lit: Int
    /// Dots in the row (the full response time in seconds).
    let total: Int
    var dotSize: CGFloat = 12
    var color: Color = MacpardyTheme.gold

    var body: some View {
        HStack(spacing: dotSize * 0.6) {
            ForEach(0..<max(total, 0), id: \.self) { index in
                // Dots on the right stay lit longest.
                let isLit = index >= total - lit
                Circle()
                    .fill(isLit ? color : color.opacity(0.18))
                    .frame(width: dotSize, height: dotSize)
            }
        }
        .animation(.easeOut(duration: 0.2), value: lit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("common.response_timer.seconds_left \(lit)"))
    }
}

#Preview {
    VStack(spacing: 16) {
        ResponseTimerDots(lit: 5, total: 5)
        ResponseTimerDots(lit: 3, total: 5)
        ResponseTimerDots(lit: 0, total: 5, dotSize: 20)
    }
    .padding()
    .background(MacpardyTheme.boardBlue)
}
