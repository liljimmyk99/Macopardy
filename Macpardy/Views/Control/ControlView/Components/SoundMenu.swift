//
//  SoundMenu.swift
//  Macpardy
//
//  Toolbar menu that switches sound effects and background music on or off.
//

import SwiftUI

struct SoundMenu: View {
    @Bindable private var sound = SoundPlayer.shared

    var body: some View {
        Menu {
            Toggle("control.toolbar.sound.effects", isOn: $sound.effectsEnabled)
            Toggle("control.toolbar.sound.music", isOn: $sound.musicEnabled)
        } label: {
            Label(
                "control.toolbar.sound",
                systemImage: sound.effectsEnabled || sound.musicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"
            )
        }
        .help("control.toolbar.sound.help")
    }
}
