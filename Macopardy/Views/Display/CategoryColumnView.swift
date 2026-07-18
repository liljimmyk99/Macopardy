//
//  CategoryColumnView.swift
//  Macopardy
//

import SwiftUI

struct CategoryColumnView: View {

    let category: Category

    var body: some View {
        VStack(spacing: 4) {
            CategoryHeaderView(title: category.title)
                .frame(height: 80)

            ForEach(category.questions) { question in
                QuestionTileView(question: question)
            }
        }
    }
}

#Preview {
    CategoryColumnView(category: JeopardyBoard.sample.categories[0])
        .frame(width: 160)
        .padding()
        .background(JeopardyTheme.boardBlue)
}
