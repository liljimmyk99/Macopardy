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
            Text("Game Title")
                .font(.headline)
                .foregroundStyle(.primary)

            TextField("My Jeopardy Game", text: $title)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 420)
                .accessibilityLabel("Game title")
        }
    }
}
