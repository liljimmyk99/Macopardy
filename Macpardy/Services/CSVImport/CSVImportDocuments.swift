//
//  CSVImportDocuments.swift
//  Macpardy
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// The downloadable CSV template.
struct CSVTemplateDocument: FileDocument {

    static var readableContentTypes: [UTType] { [.commaSeparatedText] }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

/// A board saved as plain JSON (`{ "formatVersion": 2, "boards": [...] }`),
/// which "Open Existing Game" reads like any other board file. Used for boards
/// imported from CSV, which never have pictures.
struct MacpardyJSONBoardDocument: FileDocument {

    static var readableContentTypes: [UTType] { [.json] }

    var boards: [MacpardyBoard]

    init(boards: [MacpardyBoard]) {
        self.boards = boards
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        boards = try BoardPackage.decodeBoardJSON(data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: try Self.encode(boards))
    }

    nonisolated static func encode(_ boards: [MacpardyBoard], title: String? = nil) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(BoardPackage.BoardFile(formatVersion: BoardPackage.formatVersion, boards: boards, title: title))
    }
}
