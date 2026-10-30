//
//  SettingsView.swift
//  Macopardy
//
//  The Settings window (⌘,). Changes apply as they are made.
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        TabView {
            SoundSettingsPane()
                .tabItem { Label("settings.tab.sound", systemImage: "speaker.wave.2") }

            GameSettingsPane()
                .tabItem { Label("settings.tab.game", systemImage: "gamecontroller") }

            BuzzerSettingsPane()
                .tabItem { Label("settings.tab.buzzers", systemImage: "iphone.radiowaves.left.and.right") }
        }
        .frame(width: 450)
        .scenePadding()
    }
}

#Preview {
    SettingsView()
}
