//
//  UnfilledIndicator.swift
//  Macopardy
//

import SwiftUI

extension View {

    /// Marks a field that is empty or still holds default text: a dashed
    /// outline plus an icon, so it doesn't rely on color alone.
    func unfilledIndicator(_ isUnfilled: Bool, cornerRadius: CGFloat = 6, iconAlignment: Alignment = .topTrailing) -> some View {
        modifier(UnfilledIndicator(isUnfilled: isUnfilled, cornerRadius: cornerRadius, iconAlignment: iconAlignment))
    }
}

private struct UnfilledIndicator: ViewModifier {

    let isUnfilled: Bool
    let cornerRadius: CGFloat
    let iconAlignment: Alignment

    func body(content: Content) -> some View {
        content
            .overlay {
                if isUnfilled {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(MacpardyTheme.warning, style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: iconAlignment) {
                if isUnfilled {
                    UnfilledIcon()
                        .padding(4)
                        .allowsHitTesting(false)
                }
            }
            .accessibilityValue(isUnfilled ? Text("create.unfilled.accessibility") : Text(verbatim: ""))
    }
}

/// The small warning icon used wherever a field still has default text.
struct UnfilledIcon: View {

    var body: some View {
        Image(systemName: "exclamationmark.circle.fill")
            .font(.caption)
            .foregroundStyle(MacpardyTheme.warning)
            .accessibilityLabel(Text("create.unfilled.accessibility"))
    }
}
