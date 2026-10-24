//
//  BoardLoader.swift
//  Macopardy
//

import Foundation

/// Loads a board file for "Edit game" and turns it into an editor draft.
///
/// Picks the reader by file extension and reuses the existing ones:
/// - `.json`: a plain board (`BoardPackage.decodeBoardJSON`)
/// - `.macpardy` / `.zip`: a board package with images (`BoardPackage.read`)
/// - `.csv`: a CSV board (`CSVBoardImporter`)
///
/// Nothing is partly loaded: either the whole board fits the editor or a
/// `LoadError` says what's wrong and where.
enum BoardLoader {

    enum FileKind: Equatable {
        case json
        case package
        case csv

        init?(fileExtension: String) {
            switch fileExtension.lowercased() {
            case "json": self = .json
            case BoardPackage.fileExtension, "zip": self = .package
            case "csv": self = .csv
            default: return nil
            }
        }
    }

    /// What's wrong with a JSON value, at `JSONProblem.path`.
    enum JSONProblemKind: Equatable {
        /// The data isn't JSON at all.
        case notJSON
        case missingField
        case wrongType
        case nullValue
        case invalidValue
    }

    struct JSONProblem: Equatable {
        let kind: JSONProblemKind
        /// e.g. `boards[0].categories[2].questions[1].clue`; `nil` for the whole file.
        let path: String?
        /// The JSON came from `board.json` inside a package.
        let inPackage: Bool
    }

    enum LoadError: Error, Equatable {
        case unsupportedFileType(String)
        case unreadable(String)
        case csv([CSVBoardImporter.Issue])
        case json(JSONProblem)
        case package(BoardPackage.PackageError)
        case shape(BoardDraft.ShapeError)
    }

    // MARK: - Loading

    /// Loads `data` read from a file named `fileName`. The file name picks
    /// the reader and, for CSV and boards saved without the editor's title
    /// suffix, names the game.
    ///
    /// - Throws: `LoadError`.
    static func load(data: Data, fileName: String) throws -> BoardDraft {
        let name = fileName as NSString
        let fileExtension = name.pathExtension
        let title = name.deletingPathExtension

        guard let kind = FileKind(fileExtension: fileExtension) else {
            throw LoadError.unsupportedFileType(fileExtension)
        }

        let boards = try boards(from: data, kind: kind, title: title)
        do {
            return try BoardDraft(boards: boards, fallbackTitle: title)
        } catch let error as BoardDraft.ShapeError {
            throw LoadError.shape(error)
        }
    }

    static func boards(from data: Data, kind: FileKind, title: String) throws -> [MacpardyBoard] {
        switch kind {
        case .csv:
            do {
                return try CSVBoardImporter.importBoards(from: data, title: title)
            } catch let error as CSVBoardImporter.ImportError {
                throw LoadError.csv(error.issues)
            }
        case .json:
            do {
                return try BoardPackage.decodeBoardJSON(data)
            } catch {
                throw mapped(error, inPackage: false)
            }
        case .package:
            guard BoardPackage.isZip(data) else {
                throw LoadError.package(.archiveUnreadable)
            }
            do {
                return try BoardPackage.read(data)
            } catch {
                throw mapped(error, inPackage: true)
            }
        }
    }

    // MARK: - Errors

    private static func mapped(_ error: Error, inPackage: Bool) -> LoadError {
        switch error {
        case let error as BoardPackage.PackageError:
            return .package(error)
        case let error as DecodingError:
            return .json(jsonProblem(for: error, inPackage: inPackage))
        default:
            return .unreadable(error.localizedDescription)
        }
    }

    static func jsonProblem(for error: DecodingError, inPackage: Bool) -> JSONProblem {
        switch error {
        case .keyNotFound(let key, let context):
            return JSONProblem(kind: .missingField, path: fieldPath(context.codingPath + [key]), inPackage: inPackage)
        case .typeMismatch(_, let context):
            return JSONProblem(kind: .wrongType, path: fieldPath(context.codingPath), inPackage: inPackage)
        case .valueNotFound(_, let context):
            return JSONProblem(kind: .nullValue, path: fieldPath(context.codingPath), inPackage: inPackage)
        case .dataCorrupted(let context):
            // An empty path means the bytes aren't valid JSON.
            guard let path = fieldPath(context.codingPath) else {
                return JSONProblem(kind: .notJSON, path: nil, inPackage: inPackage)
            }
            return JSONProblem(kind: .invalidValue, path: path, inPackage: inPackage)
        @unknown default:
            return JSONProblem(kind: .notJSON, path: nil, inPackage: inPackage)
        }
    }

    /// `boards[0].categories[2].title`, or `nil` for an empty path.
    static func fieldPath(_ codingPath: [CodingKey]) -> String? {
        guard !codingPath.isEmpty else { return nil }
        var path = ""
        for key in codingPath {
            if let index = key.intValue {
                path += "[\(index)]"
            } else {
                path += path.isEmpty ? key.stringValue : ".\(key.stringValue)"
            }
        }
        return path
    }
}
