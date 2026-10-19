import SwiftUI

extension FinalJeopardyView {
    func finalJeopardyHeader() -> some View {
        Text("display.final_jeopardy.header")
            .font(.system(size: 36, weight: .bold))
            .foregroundStyle(JeopardyTheme.gold)
    }
}
