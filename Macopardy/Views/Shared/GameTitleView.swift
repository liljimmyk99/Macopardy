//
//  GameTitleView.swift
//  Macopardy
//

import SwiftUI

struct GameTitleView: View {

    let title: String

    var body: some View {
        Text(title)
            .font(JeopardyTheme.titleFont)
            .foregroundStyle(.primary)
    }
}

#Preview {
    GameTitleView(title: "Jeopardy!")
}
