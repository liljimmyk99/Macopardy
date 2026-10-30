//
//  ShortcutRow.swift
//  Macpardy
//

import SwiftUI

struct ShortcutRow: View {

    let shortcut: AppShortcut

    var body: some View {
        LabeledContent {
            Text(verbatim: shortcut.glyph)
                .font(.body.monospaced())
                .foregroundStyle(.secondary)
        } label: {
            Text(LocalizedStringKey(shortcut.titleKey))
        }
    }
}
