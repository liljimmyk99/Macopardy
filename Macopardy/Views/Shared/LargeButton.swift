//
//  LargeButton.swift
//  Macopardy
//

import SwiftUI

struct LargeButton: View {

    let title: String
    var systemImage: String?
    var tint: Color = .accentColor
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
    }
}

#Preview {
    LargeButton(title: "Reveal Answer", systemImage: "eye") {}
        .padding()
}
