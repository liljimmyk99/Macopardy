import SwiftUI

extension QuestionPickerView {
    func categorySection(_ category: Category) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.title)
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                ForEach(category.questions) { question in
                    questionButton(question, categoryTitle: category.title)
                }
            }
        }
    }
}
