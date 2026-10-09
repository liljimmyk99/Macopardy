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
            ForEach(draftCategories.indices, id: \.self) { index in
                EditableCategoryHeaderView(
                    title: $draftCategories[index].title,
                    placeholder: "Category \(index + 1)"
                )
                .frame(width: 180, height: 80)
            }
        }
    }
}
