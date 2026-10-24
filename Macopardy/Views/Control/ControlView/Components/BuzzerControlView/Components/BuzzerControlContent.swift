import SwiftUI

extension BuzzerControlView {
    func buzzerControlContent() -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("control.buzzer.heading")
                    .font(.title2.bold())

                Text("control.buzzer.subheading")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 10)

            BuzzerJoinInfoView()
                .frame(maxWidth: 440)

            GroupBox {
                VStack(spacing: 12) {
                    ForEach(gameState.game.teams) { team in
                        BuzzerTeamRow(team: team)
                    }
                }
                .padding(.vertical, 4)
            } label: {
                Label("control.buzzer.teams_heading", systemImage: "person.3.fill")
                    .font(.headline)
            }
            .frame(maxWidth: 600)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
