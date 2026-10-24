//
//  FileManagerService.swift
//  Macopardy
//
//  Created by Jimmy Kane on 9/20/26.
//
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct MacpardyBoardsDocument: FileDocument {

    static var readableContentTypes: [UTType] { [.macpardyBoard, .json] }
    /// Saved as a `.macpardy` package, or as plain JSON when the exporter
    /// asks for `.json` (edited boards with no pictures).
    static var writableContentTypes: [UTType] { [.macpardyBoard, .json] }

    var boards: [MacpardyBoard]

    init(boards: [MacpardyBoard]) {
        self.boards = boards
    }

    /// Accepts a `.macpardy` package or a plain `.json` board.
    static func decodeBoards(from data: Data) throws -> [MacpardyBoard] {
        try BoardPackage.read(data)
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        boards = try Self.decodeBoards(from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        if configuration.contentType.conforms(to: .json) {
            return FileWrapper(regularFileWithContents: try MacpardyJSONBoardDocument.encode(boards))
        }
        return FileWrapper(regularFileWithContents: try BoardPackage.write(boards))
    }
}

final class FileManagerService {
    func makeExportDocument(for boards: [MacpardyBoard]) -> MacpardyBoardsDocument {
        MacpardyBoardsDocument(boards: boards)
    }

    func defaultFilename(for title: String) -> String {
        sanitizedFileName(from: title, fileExtension: BoardPackage.fileExtension)
    }

    /// File name for a board saved as plain JSON (boards imported from CSV).
    func defaultJSONFilename(for title: String) -> String {
        sanitizedFileName(from: title, fileExtension: "json")
    }

    private func sanitizedFileName(from title: String, fileExtension: String) -> String {
        let cleaned = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
            .replacingOccurrences(of: ".", with: "-")
            .replacingOccurrences(of: " ", with: "-")

        let base = cleaned.isEmpty ? "macpardy-game" : cleaned
        return "\(base).\(fileExtension)"
    }
    
    func readBoards(from url: URL) async throws -> [MacpardyBoard] {
        let hasScopedAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasScopedAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let data = try Data(contentsOf: url)
        return try MacpardyBoardsDocument.decodeBoards(from: data)
    }

    /// Reads a file the user picked (security-scoped).
    func readData(from url: URL) throws -> Data {
        let hasScopedAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasScopedAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        return try Data(contentsOf: url)
    }
}
