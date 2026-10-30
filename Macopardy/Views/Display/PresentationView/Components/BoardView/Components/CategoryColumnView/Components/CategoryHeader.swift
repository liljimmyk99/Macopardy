import SwiftUI

extension CategoryColumnView {
    func categoryHeader() -> some View {
        CategoryHeaderView(title: category.title)
            .frame(height: 80)
            .opacity(isTitleShown ? 1 : 0)
            .scaleEffect(isTitleShown ? 1 : 0.6)
            .animation(MacpardyMotion.categoryAppear, value: isTitleShown)
    }
}
