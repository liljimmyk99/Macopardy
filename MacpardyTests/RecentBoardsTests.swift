//
//  RecentBoardsTests.swift
//  MacpardyTests
//

import XCTest
@testable import Macpardy

private final class MemoryRecentsStorage: RecentBoardsStorage {
    var urls: [URL] = []
    func load() -> [URL] { urls }
    func save(_ urls: [URL]) { self.urls = urls }
}

@MainActor
final class RecentBoardsTests: XCTestCase {

    private func url(_ name: String) -> URL {
        URL(fileURLWithPath: "/tmp/\(name).macpardy")
    }

    func testNewestFirst() {
        let recents = RecentBoards(storage: MemoryRecentsStorage())
        recents.note(url("a"))
        recents.note(url("b"))
        XCTAssertEqual(recents.urls.map(\.lastPathComponent), ["b.macpardy", "a.macpardy"])
    }

    func testNotingAgainMovesToTopWithoutDuplicate() {
        let recents = RecentBoards(storage: MemoryRecentsStorage())
        recents.note(url("a"))
        recents.note(url("b"))
        recents.note(url("a"))
        XCTAssertEqual(recents.urls.map(\.lastPathComponent), ["a.macpardy", "b.macpardy"])
    }

    func testCapsAtTen() {
        let recents = RecentBoards(storage: MemoryRecentsStorage())
        for index in 0..<12 { recents.note(url("board\(index)")) }
        XCTAssertEqual(recents.urls.count, 10)
        XCTAssertEqual(recents.urls.first?.lastPathComponent, "board11.macpardy")
        XCTAssertEqual(recents.urls.last?.lastPathComponent, "board2.macpardy")
    }

    func testRemoveDropsOnlyThatEntry() {
        let recents = RecentBoards(storage: MemoryRecentsStorage())
        recents.note(url("a"))
        recents.note(url("b"))
        recents.note(url("c"))
        recents.remove(url("b"))
        XCTAssertEqual(recents.urls.map(\.lastPathComponent), ["c.macpardy", "a.macpardy"])
    }

    func testClearEmptiesTheListAndStorage() {
        let storage = MemoryRecentsStorage()
        let recents = RecentBoards(storage: storage)
        recents.note(url("a"))
        recents.clear()
        XCTAssertTrue(recents.urls.isEmpty)
        XCTAssertTrue(storage.urls.isEmpty)
    }

    func testListSurvivesRecreatingFromStorage() {
        let storage = MemoryRecentsStorage()
        RecentBoards(storage: storage).note(url("a"))
        XCTAssertEqual(RecentBoards(storage: storage).urls.map(\.lastPathComponent), ["a.macpardy"])
    }
}
