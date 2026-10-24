//
//  QuestionImage.swift
//  Macopardy
//

import AppKit
import Foundation

/// The optional picture shown with a question's clue on the display screen.
///
/// `path` is the image's location inside a board package (`images/<name>`).
/// `data` holds the encoded image bytes once loaded. It is `nil` when the
/// package referenced an image that wasn't there; the display shows a
/// placeholder in that case.
///
/// By default the bytes are encoded with the image (base64 in JSON), which is
/// how auto-saved games keep their pictures even if the board file is moved
/// or deleted. Board packages store the bytes as separate files instead and
/// encode only the path (see `CodingUserInfoKey.omitQuestionImageData`).
nonisolated struct QuestionImage: Codable, Equatable, Sendable {

    var path: String

    var data: Data?

    init(path: String, data: Data?) {
        self.path = path
        self.data = data
    }

    private enum CodingKeys: String, CodingKey {
        case path
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode(String.self, forKey: .path)
        data = try container.decodeIfPresent(Data.self, forKey: .data)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        if encoder.userInfo[.omitQuestionImageData] as? Bool != true {
            try container.encodeIfPresent(data, forKey: .data)
        }
    }

    /// The decoded image, or `nil` if the data is missing or unreadable.
    var nsImage: NSImage? {
        guard let data, ImageImporter.isDecodable(data) else { return nil }
        return NSImage(data: data)
    }
}

extension CodingUserInfoKey {
    /// When `true`, `QuestionImage` encodes only its path, not its bytes.
    nonisolated static let omitQuestionImageData = CodingUserInfoKey(rawValue: "omitQuestionImageData")!
}
