import SwiftUI

extension DailyDoubleControlView {
    func teamSelectionPicker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("control.daily_double.select_team")
                .font(.headline)

            Picker("control.daily_double.team_picker_label", selection: selectedTeamBinding) {
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
