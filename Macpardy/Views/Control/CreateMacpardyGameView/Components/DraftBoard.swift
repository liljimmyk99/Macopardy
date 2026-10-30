//
//  DraftBoard.swift
//  Macpardy
//
//  Created by Jimmy Kane on 10/8/26.
//
import SwiftUI

struct DraftBoard: View {
    @Binding var draftCategories: [DraftCategory]
    @Binding var selectedQuestion: EditingQuestion?
    let values: [Int]
    var round = 0
    var unfilled: [UnfilledField] = []
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                CategoryRow(draftCategories: $draftCategories, round: round, unfilled: unfilled)

                ForEach(Array(values.enumerated()), id: \.offset) { rowIndex, value in
                    HStack(spacing: 8) {
                        BoardRow(
                            draftCategories: $draftCategories,
                            selectedQuestion: $selectedQuestion,
                            rowIndex: rowIndex,
                            value: value,
                            round: round,
                            unfilled: unfilled
                        )
                    }
                }
            }
        }
    }
}
