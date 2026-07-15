//
//  ControlView.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//
import SwiftUI

struct ControlPanelView: View {

    @Environment private var game: GameState

    var body: some View {

        NavigationSplitView {

            CategorySidebar()

        } detail: {

            VStack {

                ScoreEditor()

                TimerControls()

                QuestionSelector()
            }
        }
    }
}
