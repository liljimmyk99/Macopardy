//
//  RoundIndictator.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/6/26.
//
import SwiftUI
struct RoundIndictator: View {
    @Binding var currentRound: Int
    
    var body: some View {
        VStack {
            HStack {
                Text("Round: ")
                Image(systemName: "1.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(currentRound == 0 ? .accentColor : .gray)
                    .symbolRenderingMode(.multicolor)
                Image(systemName: "2.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(currentRound == 1 ? .accentColor : .gray)
                    .symbolRenderingMode(.multicolor)
                Text("Final Jeopardy")
                    .foregroundStyle(currentRound == 2 ? .accentColor : .gray)
            }
        }
    }
}
