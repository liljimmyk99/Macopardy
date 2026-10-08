//
//  CategoryRow.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import SwiftUI
struct CategoryRow: View {
    @Binding var draftCategories: [DraftCategory]
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(draftCategories.enumerated()), id: \.element.id) { _, category in
                CategoryHeaderView(title: category.title)
                    .frame(width: 180, height: 80)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel(category.title)
            }
        }
    }
}
