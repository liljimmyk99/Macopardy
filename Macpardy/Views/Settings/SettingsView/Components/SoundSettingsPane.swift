//
//  SoundSettingsPane.swift
//  Macopardy
//

import SwiftUI

/// Bound straight to `SoundPlayer.shared` (not `@AppStorage`, which the
/// player's cached values would miss), so the toolbar's Sound menu and this
/// pane always agree.
struct SoundSettingsPane: View {

    @Bindable private var sound = SoundPlayer.shared

    var body: some View {
        Form {
            Toggle("control.toolbar.sound.effects", isOn: $sound.effectsEnabled)
            Toggle("control.toolbar.sound.music", isOn: $sound.musicEnabled)
        }
        .formStyle(.grouped)
    }
}
