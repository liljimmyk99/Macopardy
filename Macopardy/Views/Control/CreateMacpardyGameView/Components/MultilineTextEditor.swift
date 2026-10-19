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
    var minHeight: CGFloat = 120

    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .lineLimit(4...10)
            .padding(10)
            .background(Color(.textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(minHeight: minHeight, alignment: .topLeading)
    }
}
