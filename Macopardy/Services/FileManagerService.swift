//
//  FileManagerService.swift
//  Macopardy
//
//  Created by Jimmy Kane on 9/20/26.
//
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct JeopardyBoardDocument: FileDocument {

    static var readableContentTypes: [UTType] { [.json] }
    static var writableContentTypes: [UTType] { [.json] }

    var board: JeopardyBoard

    init(board: JeopardyBoard) {
        self.board = board
    }

    static func decodeBoard(from data: Data) throws -> JeopardyBoard {
        try JSONDecoder().decode(JeopardyBoard.self, from: data)
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        board = try Self.decodeBoard(from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return FileWrapper(regularFileWithContents: try encoder.encode(board))
    }
}

final class FileManagerService {
    func makeExportDocument(for board: JeopardyBoard) -> JeopardyBoardDocument {
        JeopardyBoardDocument(board: board)
    }

    func defaultFilename(for title: String) -> String {
        sanitizedFileName(from: title)
    }

    private func sanitizedFileName(from title: String) -> String {
        let cleaned = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
            .replacingOccurrences(of: ".", with: "-")
            .replacingOccurrences(of: " ", with: "-")

        let base = cleaned.isEmpty ? "jeopardy-game" : cleaned
        return "\(base).json"
    }
    
    func readBoard(from url: URL) async throws -> JeopardyBoard {
        let hasScopedAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasScopedAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let data = try Data(contentsOf: url)
        return try JeopardyBoardDocument.decodeBoard(from: data)
    }
}
