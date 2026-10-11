import SwiftUI

extension DailyDoubleControlView {
    func teamSelectionPicker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Wagering Team:")
                .font(.headline)

            Picker("Team", selection: selectedTeamBinding) {
                ForEach(gameState.game.teams) { team in
                    HStack {
                        Circle()
                            .fill(team.displayColor)
                            .frame(width: 8, height: 8)
                        Text("\(team.name) ($\(team.score))")
                    }
                    .tag(team.id)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
