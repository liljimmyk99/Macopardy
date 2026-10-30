//
//  KeyboardShortcutsView.swift
//  Macpardy
//
//  Every shortcut in the app, read from `ShortcutCatalog`.
//

import SwiftUI

struct KeyboardShortcutsView: View {

    var body: some View {
        Form {
            ForEach(ShortcutGroups.all()) { group in
                Section(LocalizedStringKey(group.area.titleKey)) {
                    ForEach(group.shortcuts) { shortcut in
                        ShortcutRow(shortcut: shortcut)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 600)
    }
}

#Preview {
    KeyboardShortcutsView()
}
