//
//  LaunchActionTile.swift
//  Macopardy
//
//  A start-screen action drawn as a board column: category-style header
//  over a tile with an icon, caption and keyboard shortcut.
//

import SwiftUI

struct LaunchActionTile: View {

    let title: LocalizedStringKey
    let caption: LocalizedStringKey
    let systemImage: String
    let shortcut: KeyEquivalent
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .textCase(.uppercase)
                    .font(MacpardyTheme.categoryFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(MacpardyTheme.tileBlue)

                VStack(spacing: 14) {
                    Image(systemName: systemImage)
                        .font(MacpardyTheme.launchTileIconFont)
                        .foregroundStyle(MacpardyTheme.gold)

                    Text(caption)
                        .font(.callout)
                        .foregroundStyle(MacpardyTheme.mutedText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(verbatim: "⌘" + String(shortcut.character).uppercased())
                        .font(MacpardyTheme.shortcutFont)
                        .foregroundStyle(MacpardyTheme.mutedText)
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(isHovered ? MacpardyTheme.tileHover : MacpardyTheme.tileBlue)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .keyboardShortcut(shortcut, modifiers: .command)
        .onHover { isHovered = $0 }
    }
}

#Preview {
    LaunchActionTile(
        title: "launch.tile.play",
        caption: "launch.tile.play.caption",
        systemImage: "play.fill",
        shortcut: "o"
    ) {}
    .frame(width: 320)
    .padding()
    .background(MacpardyTheme.boardBlue)
}
