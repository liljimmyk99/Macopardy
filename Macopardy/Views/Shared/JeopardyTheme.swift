//
//  JeopardyTheme.swift
//  Macopardy
//

import SwiftUI

enum JeopardyTheme {

    static let boardBlue = Color(red: 0.04, green: 0.12, blue: 0.38)
    static let tileBlue = Color(red: 0.06, green: 0.18, blue: 0.48)
    static let tilePlayed = Color(red: 0.04, green: 0.12, blue: 0.38)
    static let gold = Color(red: 0.88, green: 0.75, blue: 0.22)
    static let clueBackground = Color(red: 0.04, green: 0.12, blue: 0.38)
    static let controlBackground = Color(nsColor: .windowBackgroundColor)
    static let sidebarBackground = Color(nsColor: .controlBackgroundColor)

    static let categoryFont = Font.system(size: 22, weight: .bold, design: .default)
    static let valueFont = Font.system(size: 36, weight: .bold, design: .default)
    static let clueFont = Font.system(size: 48, weight: .regular, design: .default)
    static let answerFont = Font.system(size: 56, weight: .bold, design: .default)
    static let titleFont = Font.system(size: 32, weight: .bold, design: .default)
    static let scoreFont = Font.system(size: 28, weight: .bold, design: .default)
    static let timerFont = Font.system(size: 72, weight: .bold, design: .monospaced)
    static let dailyDoubleFont = Font.system(size: 96, weight: .bold, design: .default)
}
