//
//  BoardLoader+Messages.swift
//  Macopardy
//

import Foundation

/// One problem to show the user: where it is (if it's in a particular
/// place) and what's wrong.
struct BoardLoadProblem: Identifiable, Equatable {
    let id = UUID()
    let location: String?
    let message: String

    static func == (lhs: BoardLoadProblem, rhs: BoardLoadProblem) -> Bool {
        lhs.location == rhs.location && lhs.message == rhs.message
    }
}

/// A file that couldn't be opened for editing, ready to show.
struct BoardLoadReport: Identifiable {
    let id = UUID()
    let fileName: String
    let problems: [BoardLoadProblem]

    init(fileName: String, error: Error) {
        self.fileName = fileName
        if let error = error as? BoardLoader.LoadError {
            problems = error.problems
        } else {
            problems = BoardLoader.LoadError.unreadable(error.localizedDescription).problems
        }
    }
}

extension BoardLoader.LoadError {

    /// Every problem, in the user's language. CSV files can have several.
    var problems: [BoardLoadProblem] {
        switch self {
        case .unsupportedFileType(let fileExtension):
            return [BoardLoadProblem(
                location: nil,
                message: String(localized: "board_load.error.unsupported_type \(fileExtension)")
            )]
        case .unreadable(let detail):
            return [BoardLoadProblem(
                location: nil,
                message: String(localized: "board_load.error.unreadable \(detail)")
            )]
        case .csv(let issues):
            return issues.map { BoardLoadProblem(location: $0.location, message: $0.message) }
        case .json(let problem):
            return [problem.displayProblem]
        case .package(let error):
            return [BoardLoadProblem(location: nil, message: error.message)]
        case .shape(let error):
            return [error.displayProblem]
        }
    }
}

extension BoardLoader.JSONProblem {

    var displayProblem: BoardLoadProblem {
        let location: String?
        switch (path, inPackage) {
        case let (path?, true):
            location = String(localized: "board_load.location.package_field \(path)")
        case let (path?, false):
            location = String(localized: "board_load.location.field \(path)")
        case (nil, true):
            location = BoardPackage.boardFileName
        case (nil, false):
            location = nil
        }

        let message = switch kind {
        case .notJSON: String(localized: "board_load.error.not_json")
        case .missingField: String(localized: "board_load.error.missing_field")
        case .wrongType: String(localized: "board_load.error.wrong_type")
        case .nullValue: String(localized: "board_load.error.null_value")
        case .invalidValue: String(localized: "board_load.error.invalid_value")
        }

        return BoardLoadProblem(location: location, message: message)
    }
}

extension BoardPackage.PackageError {

    var message: String {
        switch self {
        case .missingBoardFile:
            String(localized: "board_load.error.package.missing_board")
        case .unsupportedFormatVersion(let version):
            String(localized: "board_load.error.package.newer_format \(version)")
        case .archiveUnreadable, .archiveWriteFailed:
            String(localized: "board_load.error.package.unreadable")
        }
    }
}

extension BoardDraft.ShapeError {

    var displayProblem: BoardLoadProblem {
        switch self {
        case .missingRound(let round):
            BoardLoadProblem(
                location: nil,
                message: String(localized: "board_load.error.missing_round \(round.displayName)")
            )
        case .duplicateRound(let round):
            BoardLoadProblem(
                location: nil,
                message: String(localized: "board_load.error.duplicate_round \(round.displayName)")
            )
        case .emptyRound(let round):
            BoardLoadProblem(
                location: String(localized: "board_load.location.round \(round.displayName)"),
                message: String(localized: "board_load.error.empty_round")
            )
        case .emptyCategory(let round, let category):
            BoardLoadProblem(
                location: String(localized: "board_load.location.round_category \(round.displayName) \(category)"),
                message: String(localized: "board_load.error.empty_category")
            )
        case .mismatchedValues(let round, let category, let expected, let found):
            BoardLoadProblem(
                location: String(localized: "board_load.location.round_category \(round.displayName) \(category)"),
                message: String(localized: "board_load.error.mismatched_values \(Self.list(found)) \(Self.list(expected))")
            )
        case .finalShape(let categories, let questions):
            BoardLoadProblem(
                location: String(localized: "board_load.location.round \(MacpardyRound.finalMacpardy.displayName)"),
                message: String(localized: "board_load.error.final_shape \(categories) \(questions)")
            )
        }
    }

    private static func list(_ values: [Int]) -> String {
        values.map(String.init).formatted(.list(type: .and))
    }
}

extension MacpardyRound {

    /// The round's name, e.g. "Double Macpardy".
    var displayName: String {
        switch self {
        case .macpardy: String(localized: "round.macpardy")
        case .doubleMacpardy: String(localized: "round.double_macpardy")
        case .finalMacpardy: String(localized: "round.final_macpardy")
        }
    }
}
