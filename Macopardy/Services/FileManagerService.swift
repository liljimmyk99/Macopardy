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

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        board = try JSONDecoder().decode(JeopardyBoard.self, from: data)
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
    
    // Read File
    func readBoard() async throws -> JeopardyBoard {
        return JeopardyBoard.sample
    }
}
