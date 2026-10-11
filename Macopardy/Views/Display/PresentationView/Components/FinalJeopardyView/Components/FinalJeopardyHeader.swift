import SwiftUI

extension FinalJeopardyView {
    func finalJeopardyHeader() -> some View {
        Text("FINAL JEOPARDY")
            .font(.system(size: 36, weight: .bold))
            .foregroundStyle(JeopardyTheme.gold)
    }
}
