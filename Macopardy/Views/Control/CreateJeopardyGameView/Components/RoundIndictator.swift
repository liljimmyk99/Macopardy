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
        HStack(spacing: 12) {
            Text("Round:")
                .font(.headline)
                .foregroundStyle(.primary)

            Button {
                currentRound = 0
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "1.circle.fill")
                        .imageScale(.medium)
                    Text("Jeopardy")
                        .fontWeight(currentRound == 0 ? .bold : .regular)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(currentRound == 0 ? JeopardyTheme.tileBlue : Color.clear)
                .foregroundStyle(currentRound == 0 ? JeopardyTheme.gold : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(currentRound == 0 ? JeopardyTheme.gold : Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Button {
                currentRound = 1
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "2.circle.fill")
                        .imageScale(.medium)
                    Text("Double Jeopardy")
                        .fontWeight(currentRound == 1 ? .bold : .regular)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(currentRound == 1 ? JeopardyTheme.tileBlue : Color.clear)
                .foregroundStyle(currentRound == 1 ? JeopardyTheme.gold : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(currentRound == 1 ? JeopardyTheme.gold : Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Button {
                currentRound = 2
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "flag.checkered")
                        .imageScale(.medium)
                    Text("Final Jeopardy")
                        .fontWeight(currentRound == 2 ? .bold : .regular)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(currentRound == 2 ? JeopardyTheme.tileBlue : Color.clear)
                .foregroundStyle(currentRound == 2 ? JeopardyTheme.gold : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(currentRound == 2 ? JeopardyTheme.gold : Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}
