import SwiftUI

extension FinalJeopardyView {
    func finalJeopardyContent() -> some View {
        VStack(spacing: 36) {
            Spacer()
            finalJeopardyHeader()
            finalJeopardyCategory()
            finalJeopardyPhaseContent()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(JeopardyTheme.clueBackground)
    }
}
