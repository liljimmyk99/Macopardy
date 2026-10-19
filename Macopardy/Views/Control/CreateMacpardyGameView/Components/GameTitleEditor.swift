//
//  GameTitleEditor.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//

import SwiftUI
struct GameTitleEditor: View {
    @Binding var title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("create.title_label")
                .font(.headline)
                .foregroundStyle(.primary)

            TextField("create.title_placeholder", text: $title)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 420)
                .accessibilityLabel(Text("create.title_accessibility"))
        }
    }
}
