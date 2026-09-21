//
//  FileManagerService.swift
//  Macopardy
//
//  Created by Jimmy Kane on 9/20/26.
//
import Foundation

final class FileManagerService {
    // Save File
    func saveBoardToStorage(title: String, board: JeopardyBoard, onError: (String) -> Void) throws {
        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(board)
        
        // Save file
        let fileManager = FileManager.default

        guard let desktopURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            onError("The desktop directory could not be located. Please try again.")
            return
        }

        let filename = uniqueDesktopFileName(base: title)
        let destinationURL = desktopURL.appendingPathComponent(filename)

        do {
            try data.write(to: destinationURL)
        } catch {
            onError("The game could not be saved to the desktop.\n\(error.localizedDescription)")
        }
    }
    
    private func uniqueDesktopFileName(base: String) -> String {
        let fileManager = FileManager.default

        guard let desktopURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return sanitizedFileName(from: base)
        }

        let baseName = sanitizedFileName(from: base)
        let baseURL = desktopURL.appendingPathComponent(baseName)

        if !fileManager.fileExists(atPath: baseURL.path) {
            return baseName
        }

        let nameWithoutExtension = (baseName as NSString).deletingPathExtension
        let extensionName = (baseName as NSString).pathExtension

        var counter = 1
        while true {
            let candidateName = extensionName.isEmpty
                ? "\(nameWithoutExtension) \(counter)"
                : "\(nameWithoutExtension) \(counter).\(extensionName)"
            let candidateURL = desktopURL.appendingPathComponent(candidateName)
            if !fileManager.fileExists(atPath: candidateURL.path) {
                return candidateName
            }
            counter += 1
        }
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
