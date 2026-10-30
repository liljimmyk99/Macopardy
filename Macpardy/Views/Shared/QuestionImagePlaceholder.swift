//
//  QuestionImagePlaceholder.swift
//  Macopardy
//

import SwiftUI

/// Shown in place of an image that is missing or can't be decoded.
/// Callers set the foreground style to suit their background.
struct QuestionImagePlaceholder: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.largeTitle)
            Text("question.image_unavailable")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}
