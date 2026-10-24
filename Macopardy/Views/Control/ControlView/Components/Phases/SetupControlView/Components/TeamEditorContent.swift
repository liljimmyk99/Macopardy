import SwiftUI

extension TeamEditorView {
    @ViewBuilder
    func teamEditorContent() -> some View {
        VStack(spacing: 12) {
            ForEach(gameState.game.teams) { team in
                teamRow(for: team)
            }

            addTeamButton()
        }
        .padding(.vertical, 4)
    }

    func teamEditorHeader() -> some View {
        HStack {
            Text("control.setup.teams_heading")
                .font(.headline)
            Spacer()
            Text("control.setup.team_count \(gameState.game.teams.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    func addTeamButton() -> some View {
        HStack {
            Button {
                gameState.addTeam()
            } label: {
                Label("control.setup.button.add_team", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)
            .tint(.accentColor)
            .disabled(gameState.game.teams.count >= Team.maxCount)

            Spacer()
        }
        .padding(.top, 4)
    }

    /// Shows whether a phone holds the team, with a button for the host to remove it.
    @ViewBuilder
    func phoneStatus(for team: Team) -> some View {
        if buzzerState.claimedTeamIDs.contains(team.id) {
            Button {
                Task { await buzzerState.removePhone(forTeam: team.id) }
            } label: {
                Label("control.team.remove_phone", systemImage: "iphone.slash")
            }
            .help("control.team.remove_phone.help")
        } else if buzzerState.disconnectedTeamIDs.contains(team.id) {
            Label("control.team.disconnected", systemImage: "iphone.slash")
                .font(.caption)
                .foregroundStyle(.orange)
        }
    }

    func teamRow(for team: Team) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(team.displayColor)
                .frame(width: 16, height: 16)

            TextField("control.setup.team_name_placeholder", text: Binding(
                get: {
                    gameState.game.teams.first(where: { $0.id == team.id })?.name ?? team.name
                },
                set: { newName in
                    if let index = gameState.game.teams.firstIndex(where: { $0.id == team.id }) {
                        gameState.game.teams[index].name = newName
                    }
                }
            ))
            .textFieldStyle(.roundedBorder)

            Picker("control.setup.color_picker_label", selection: Binding(
                get: {
                    gameState.game.teams.first(where: { $0.id == team.id })?.color ?? team.color
                },
                set: { newColor in
                    if let index = gameState.game.teams.firstIndex(where: { $0.id == team.id }) {
                        gameState.game.teams[index].color = newColor
                    }
                }
            )) {
                ForEach(colorOptions, id: \.self) { color in
                    Text(LocalizedStringKey("color.\(color)")).tag(color)
                }
            }
            .labelsHidden()
            .frame(width: 120)

            phoneStatus(for: team)

            if gameState.game.teams.count > 1 {
                Button {
                    gameState.removeTeam(id: team.id)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .help("Delete Team")
            }
        }
    }
}
