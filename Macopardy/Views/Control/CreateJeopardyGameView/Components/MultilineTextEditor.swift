//
//  MultilineTextEditor.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import SwiftUI

struct MultilineTextEditor: View {

    @Binding
    var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
                    .padding(.top, 10)
            }

            TextEditor(text: $text)
                .padding(4)
                .background(Color(.textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(minHeight: 120)
                .opacity(text.isEmpty ? 0.8 : 1)
        }
    }
}
