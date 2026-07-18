//
//  CategoryHeaderView.swift
//  Macopardy
//

import SwiftUI

struct CategoryHeaderView: View {

    let title: String
    var font: Font = JeopardyTheme.categoryFont

    var body: some View {
        Text(title.uppercased())
            .font(font)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 8)
            .background(JeopardyTheme.tileBlue)
    }
}

#Preview {
    CategoryHeaderView(title: "Science")
        .frame(width: 160, height: 80)
}
