//
//  GameTitleView.swift
//  Macpardy
//

import SwiftUI

struct GameTitleView: View {

    let title: String

    var body: some View {
        Text(title)
            .font(MacpardyTheme.titleFont)
            .foregroundStyle(.primary)
    }
}

#Preview {
    GameTitleView(title: "Macpardy!")
}
