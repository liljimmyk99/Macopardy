//
//  QuestionImageDisplay.swift
//  Macopardy
//

import AppKit
import SwiftUI

/// The question's picture on the display screen: fitted, never cropped.
/// Shows a placeholder if the image is missing or can't be decoded.
struct QuestionImageDisplay: View {

    let image: QuestionImage

    /// Decoded once per image rather than on every redraw (the timer ticks).
    @State private var decoded: NSImage?
    @State private var didDecode = false

    var body: some View {
        Group {
            if let decoded {
                Image(nsImage: decoded)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)
                    .accessibilityLabel(Text("display.question.image_accessibility"))
            } else if didDecode {
                QuestionImagePlaceholder()
                    .foregroundStyle(.white.opacity(0.7))
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            } else {
                Color.clear
            }
        }
        .task(id: image) {
            decoded = image.nsImage
            didDecode = true
        }
    }
}
