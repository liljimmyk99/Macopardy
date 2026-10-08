//
//  DraftBoard.swift
//  Macopardy
//
//  Created by Jimmy Kane on 10/8/26.
//
import SwiftUI

struct DraftBoard: View {
    @Binding var draftCategories: [DraftCategory]
    @Binding var selectedQuestion: EditingQuestion?
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                CategoryRow(draftCategories: $draftCategories)

                ForEach(Array(CreateJeopardyGameView.values.enumerated()), id: \.offset) { rowIndex, value in
                    HStack(spacing: 8) {
                        BoardRow(
                            draftCategories: $draftCategories,
                            selectedQuestion: $selectedQuestion,
                            rowIndex: rowIndex,
                            value: value
                        )
                    }
                }
            }
        }
    }
}
