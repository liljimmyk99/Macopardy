//
//  PhaseContent.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/10/26.
//
import SwiftUI

extension SidebarView {
    
    @ViewBuilder
    func phaseContent() -> some View {
        HStack {
            Image(systemName: phaseIcon)
                .foregroundStyle(JeopardyTheme.gold)
            Text(phaseLabel)
                .fontWeight(.medium)
        }
    }
}
