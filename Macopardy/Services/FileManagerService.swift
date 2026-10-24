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
    static var writableContentTypes: [UTType] { [.macpardyBoard] }

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
        FileWrapper(regularFileWithContents: try BoardPackage.write(boards))
    }
}

final class FileManagerService {
    func makeExportDocument(for boards: [MacpardyBoard]) -> MacpardyBoardsDocument {
        MacpardyBoardsDocument(boards: boards)
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

        let base = cleaned.isEmpty ? "macpardy-game" : cleaned
        return "\(base).\(BoardPackage.fileExtension)"
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
}
