import SwiftUI

extension FinalMacpardyView {
    func finalMacpardyHeader() -> some View {
        Text("display.final_macpardy.header")
            .font(.system(size: 36, weight: .bold))
            .foregroundStyle(MacpardyTheme.gold)
    }
}
