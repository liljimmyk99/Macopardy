import SwiftUI

struct DailyDoubleView: View {

    @Environment(\.animationsEnabled) var animationsEnabled

    var body: some View {
        dailyDoubleContent()
    }
}

#Preview {
    DailyDoubleView()
        .frame(width: 960, height: 540)
}
