//
//  EditableCategoryHeaderView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/8/26.
//

import SwiftUI

struct EditableCategoryHeaderView: View {
    @Binding var title: String
    var placeholder: String = "Category"
    var font: Font = JeopardyTheme.categoryFont

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            JeopardyTheme.tileBlue

            TextField(
                "",
                text: $title,
                prompt: Text(placeholder.uppercased())
                    .font(font)
                    .foregroundColor(.white.opacity(0.45))
            )
            .font(font)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .textFieldStyle(.plain)
            .padding(.horizontal, 8)
            .focused($isFocused)
            .accessibilityLabel("Category: \(title.isEmpty ? placeholder : title)")
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isFocused ? JeopardyTheme.gold : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    EditableCategoryHeaderView(
        title: .constant("Science"),
        placeholder: "Category 1"
    )
    .frame(width: 180, height: 80)
}
