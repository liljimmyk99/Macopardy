import SwiftUI

extension FinalMacpardyView {
    func finalMacpardyContent() -> some View {
        VStack(spacing: 36) {
            Spacer()
            finalMacpardyHeader()
            finalMacpardyCategory()
            finalMacpardyPhaseContent()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MacpardyTheme.clueBackground)
    }
}
