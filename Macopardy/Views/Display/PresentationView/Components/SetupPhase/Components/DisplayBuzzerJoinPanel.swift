//
//  DisplayBuzzerJoinPanel.swift
//  Macopardy
//
//  Big QR code, join URL and join code on the Display before the game starts,
//  so teams can scan from across the room.
//

import SwiftUI

struct DisplayBuzzerJoinPanel: View {

    let url: URL
    let joinCode: String

    var body: some View {
        HStack(spacing: 48) {
            if let qrImage = QRCodeGenerator.image(from: url.absoluteString, size: 600) {
                Image(nsImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 320, maxHeight: 320)
                    .padding(16)
                    // White quiet zone so phone cameras pick the code up on a dark board.
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))
            }

            VStack(alignment: .leading, spacing: 20) {
                Text("display.setup.buzzer.scan")
                    .font(MacpardyTheme.titleFont)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 6) {
                    Text("display.setup.buzzer.or_visit")
                        .font(.title3)
                        .foregroundStyle(MacpardyTheme.mutedText)
                    Text(url.absoluteString)
                        .font(MacpardyTheme.displayJoinURLFont)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .textSelection(.enabled)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("display.setup.buzzer.join_code")
                        .font(.title3)
                        .foregroundStyle(MacpardyTheme.mutedText)
                    Text(joinCode)
                        .font(MacpardyTheme.displayJoinCodeFont)
                        .foregroundStyle(MacpardyTheme.gold)
                        .tracking(10)
                }
            }
        }
    }
}

#Preview {
    DisplayBuzzerJoinPanel(url: URL(string: "http://192.168.1.20:8080?code=ABC234")!, joinCode: "ABC234")
        .padding()
        .background(MacpardyTheme.boardBlue)
}
