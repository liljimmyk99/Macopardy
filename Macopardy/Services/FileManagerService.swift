//
//  FileManagerService.swift
//  Macopardy
//
//  Created by Jimmy Kane on 9/20/26.
//
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct JeopardyBoardsDocument: FileDocument {

    static var readableContentTypes: [UTType] { [.json] }
    static var writableContentTypes: [UTType] { [.json] }

    var boards: [JeopardyBoard]

    init(boards: [JeopardyBoard]) {
        self.boards = boards
    }

    static func decodeBoards(from data: Data) throws -> [JeopardyBoard] {
        try JSONDecoder().decode([JeopardyBoard].self, from: data)
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        boards = try Self.decodeBoards(from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return FileWrapper(regularFileWithContents: try encoder.encode(boards))
    }
}

final class FileManagerService {
    func makeExportDocument(for boards: [JeopardyBoard]) -> JeopardyBoardsDocument {
        JeopardyBoardsDocument(boards: boards)
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
    
    func readBoards(from url: URL) async throws -> [JeopardyBoard] {
        let hasScopedAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasScopedAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let data = try Data(contentsOf: url)
        return try JeopardyBoardsDocument.decodeBoards(from: data)
    }
}
