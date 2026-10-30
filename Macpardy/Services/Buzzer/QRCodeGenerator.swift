//
//  QRCodeGenerator.swift
//  Macpardy
//
//  Generates a QR code NSImage using Core Image (no third-party library required).
//

import AppKit
import CoreImage

enum QRCodeGenerator {

    /// Returns an `NSImage` containing a QR code encoding `string` at the given
    /// pixel `size`. Returns `nil` if Core Image is unavailable or the string
    /// cannot be encoded.
    static func image(from string: String, size: CGFloat = 200) -> NSImage? {
        // CIQRCodeGenerator requires ISO-Latin-1 encoded data.
        guard let data = string.data(using: .isoLatin1),
              let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        // "M" = ~15% error correction — adequate for display purposes.
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let output = filter.outputImage else { return nil }

        // Scale up from the tiny native size to the requested pixel size.
        let scale = size / output.extent.width
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let rep = NSCIImageRep(ciImage: scaled)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}
