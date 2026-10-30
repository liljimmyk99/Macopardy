//
//  RoundTitleEditor.swift
//  Macopardy
//

import SwiftUI

/// The title of the round being edited. Left blank, the round is saved
/// with its default name (e.g. "Double Macpardy").
struct RoundTitleEditor: View {

    @Binding var title: String
    let round: MacpardyRound
    var isUnfilled = false

    var body: some View {
        HStack(spacing: 12) {
            Text("create.round_title_label")
                .font(.headline)
                .foregroundStyle(.primary)

            TextField(BoardDraft.defaultTitle(for: round), text: $title)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 420)
                .unfilledIndicator(isUnfilled, cornerRadius: 5)
                .accessibilityLabel(Text("create.round_title_accessibility \(round.displayName)"))
        }
    }
}

#Preview {
    RoundTitleEditor(title: .constant("Science Night: Round 1"), round: .macpardy)
        .padding()
}
