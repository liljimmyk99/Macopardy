//
//  BuzzerJoinInfoView.swift
//  Macopardy
//
//  QR code, copyable link, join code and connected-phone count. Shared by the
//  setup screen and the buzzer tab.
//

import AppKit
import SwiftUI

struct BuzzerJoinInfoView: View {

    @Environment(BuzzerState.self) var buzzerState

    var body: some View {
        GroupBox {
            VStack(spacing: 16) {
                if buzzerState.isRunning, let url = buzzerState.serverURL {
                    // QR code
                    if let qrImage = QRCodeGenerator.image(from: url.absoluteString, size: 200) {
                        Image(nsImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // URL (tap to copy)
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(url.absoluteString, forType: .string)
                    } label: {
                        HStack(spacing: 6) {
                            Text(url.absoluteString)
                                .font(.system(.caption, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("control.setup.buzzer.copy_url")

                    // Join code
                    VStack(spacing: 4) {
                        Text("control.setup.buzzer.join_code")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(buzzerState.joinCode)
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundStyle(MacpardyTheme.gold)
                            .tracking(8)
                    }

                    // Connected clients
                    Label(
                        "control.setup.buzzer.phones_connected \(buzzerState.connectedClientCount)",
                        systemImage: buzzerState.connectedClientCount > 0
                            ? "iphone.badge.play"
                            : "iphone"
                    )
                    .font(.callout)
                    .foregroundStyle(
                        buzzerState.connectedClientCount > 0 ? Color.green : Color.secondary
                    )

                } else if let error = buzzerState.startError {
                    Label {
                        Text("control.setup.buzzer.error \(error)")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                    .font(.callout)
                    .foregroundStyle(.red)
                } else {
                    // Server not running yet
                    ProgressView()
                        .padding(.vertical, 8)
                    Text("control.setup.buzzer.starting")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 360)
            .padding(.vertical, 8)
        } label: {
            Label("control.setup.buzzer.title", systemImage: "iphone.gen3")
                .font(.headline)
        }
        .frame(maxWidth: 440)
    }
}

#Preview {
    BuzzerJoinInfoView()
        .environment(BuzzerState())
        .padding()
}
