import SwiftUI

extension CategoryColumnView {
    func categoryHeader() -> some View {
        CategoryHeaderView(title: category.title)
            .frame(height: 80)
    }
}
