//
//  TeamClaimRegistryTests.swift
//  MacpardyTests
//

import XCTest
@testable import Macpardy

@MainActor
final class TeamClaimRegistryTests: XCTestCase {

    private let teamA = UUID()
    private let teamB = UUID()
    private let phone1 = UUID()
    private let phone2 = UUID()
    private var valid: Set<UUID> { [teamA, teamB] }

    func testClaimFreeTeam() {
        var registry = TeamClaimRegistry()
        XCTAssertEqual(registry.claim(teamID: teamA, sessionID: phone1, validTeamIDs: valid), .claimed)
        XCTAssertTrue(registry.isClaimed(teamA))
        XCTAssertEqual(registry.claimedTeamIDs, [teamA])
    }

    func testSecondPhoneIsBlockedFromClaimedTeam() {
        var registry = TeamClaimRegistry()
        _ = registry.claim(teamID: teamA, sessionID: phone1, validTeamIDs: valid)
        XCTAssertEqual(registry.claim(teamID: teamA, sessionID: phone2, validTeamIDs: valid), .taken)
        XCTAssertEqual(registry.sessionID(for: teamA), phone1)
    }

    func testSamePhoneClaimingAgainIsHarmless() {
        var registry = TeamClaimRegistry()
        _ = registry.claim(teamID: teamA, sessionID: phone1, validTeamIDs: valid)
        XCTAssertEqual(registry.claim(teamID: teamA, sessionID: phone1, validTeamIDs: valid), .alreadyHeld)
    }

    func testUnknownTeamIsInvalid() {
        var registry = TeamClaimRegistry()
        XCTAssertEqual(registry.claim(teamID: UUID(), sessionID: phone1, validTeamIDs: valid), .invalidTeam)
        XCTAssertTrue(registry.claimedTeamIDs.isEmpty)
    }

    func testPhoneHoldsOneTeamAtATime() {
        var registry = TeamClaimRegistry()
        _ = registry.claim(teamID: teamA, sessionID: phone1, validTeamIDs: valid)
        XCTAssertEqual(registry.claim(teamID: teamB, sessionID: phone1, validTeamIDs: valid), .claimed)
        XCTAssertFalse(registry.isClaimed(teamA))
        XCTAssertTrue(registry.isClaimed(teamB))
    }

    func testReleaseFreesSlotForRejoin() {
        var registry = TeamClaimRegistry()
        _ = registry.claim(teamID: teamA, sessionID: phone1, validTeamIDs: valid)
        XCTAssertEqual(registry.release(sessionID: phone1), teamA)
        XCTAssertEqual(registry.claim(teamID: teamA, sessionID: phone2, validTeamIDs: valid), .claimed)
    }

    func testSweepFreesClaimsOfDeadSessions() {
        var registry = TeamClaimRegistry()
        _ = registry.claim(teamID: teamA, sessionID: phone1, validTeamIDs: valid)
        _ = registry.claim(teamID: teamB, sessionID: phone2, validTeamIDs: valid)
        let freed = registry.sweep(liveSessionIDs: [phone2])
        XCTAssertEqual(freed, [teamA])
        XCTAssertFalse(registry.isClaimed(teamA))
        XCTAssertTrue(registry.isClaimed(teamB))
    }

    func testRemoveFreesTeamAndReturnsHolder() {
        var registry = TeamClaimRegistry()
        _ = registry.claim(teamID: teamA, sessionID: phone1, validTeamIDs: valid)
        XCTAssertEqual(registry.remove(teamID: teamA), phone1)
        XCTAssertFalse(registry.isClaimed(teamA))
        XCTAssertNil(registry.remove(teamID: teamA))
    }

    func testPruneDropsClaimsOnDeletedTeams() {
        var registry = TeamClaimRegistry()
        _ = registry.claim(teamID: teamA, sessionID: phone1, validTeamIDs: valid)
        _ = registry.claim(teamID: teamB, sessionID: phone2, validTeamIDs: valid)
        XCTAssertEqual(registry.prune(validTeamIDs: [teamB]), [phone1])
        XCTAssertEqual(registry.claimedTeamIDs, [teamB])
    }
}
