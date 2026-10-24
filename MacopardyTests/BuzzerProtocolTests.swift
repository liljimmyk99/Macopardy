//
//  BuzzerProtocolTests.swift
//  MacopardyTests
//

import XCTest
@testable import Macopardy

@MainActor
final class BuzzerProtocolTests: XCTestCase {

    func testJoinCodeLengthAndAlphabet() {
        let allowed = Set("ABCDEFGHJKMNPQRSTUVWXYZ23456789")
        for _ in 0..<200 {
            let code = JoinCodeGenerator.generate()
            XCTAssertEqual(code.count, 6)
            XCTAssertTrue(code.allSatisfy { allowed.contains($0) }, code)
        }
    }

    func testJoinMessageDecodes() throws {
        let json = Data(#"{"type":"join","version":1,"code":"AB3XYZ"}"#.utf8)
        let message = try JSONDecoder().decode(ClientMessage.self, from: json)
        guard case .join(let code, let version) = message else { return XCTFail("expected join") }
        XCTAssertEqual(code, "AB3XYZ")
        XCTAssertEqual(version, 1)
    }

    func testJoinWithoutVersionIsRejected() {
        let json = Data(#"{"type":"join","code":"AB3XYZ"}"#.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(ClientMessage.self, from: json))
    }

    func testPongDecodesAndUnknownTypeThrows() throws {
        let pong = try JSONDecoder().decode(ClientMessage.self, from: Data(#"{"type":"pong"}"#.utf8))
        guard case .pong = pong else { return XCTFail("expected pong") }
        XCTAssertThrowsError(
            try JSONDecoder().decode(ClientMessage.self, from: Data(#"{"type":"nope"}"#.utf8))
        )
    }

    func testBuzzDecodes() throws {
        let buzz = try JSONDecoder().decode(ClientMessage.self, from: Data(#"{"type":"buzz"}"#.utf8))
        guard case .buzz = buzz else { return XCTFail("expected buzz") }
    }

    func testBuzzerStateEncoding() throws {
        let data = try ServerMessage.buzzerState(.lockedOut).jsonData()
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["type"] as? String, "buzzerState")
        let payload = try XCTUnwrap(json["payload"] as? [String: Any])
        XCTAssertEqual(payload["state"] as? String, "lockedOut")
    }

    func testJoinAcceptedEncoding() throws {
        let id = UUID()
        let team = BuzzerTeam(id: id, name: "A", color: "blue", claimed: true)
        let data = try ServerMessage.joinAccepted(teams: [team]).jsonData()
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["type"] as? String, "joinAccepted")
        let payload = try XCTUnwrap(object["payload"] as? [String: Any])
        XCTAssertEqual(payload["version"] as? Int, BuzzerConstants.protocolVersion)
        let teams = try XCTUnwrap(payload["teams"] as? [[String: Any]])
        XCTAssertEqual(teams.first?["id"] as? String, id.uuidString)
        XCTAssertEqual(teams.first?["name"] as? String, "A")
        XCTAssertEqual(teams.first?["claimed"] as? Bool, true)
    }

    func testClaimDecodes() throws {
        let id = UUID()
        let json = Data(#"{"type":"claim","teamID":"\#(id.uuidString)"}"#.utf8)
        let message = try JSONDecoder().decode(ClientMessage.self, from: json)
        guard case .claim(let teamID) = message else { return XCTFail("expected claim") }
        XCTAssertEqual(teamID, id)
    }

    func testClaimWithBadTeamIDIsRejected() {
        let json = Data(#"{"type":"claim","teamID":"nope"}"#.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(ClientMessage.self, from: json))
    }

    func testClaimRejectedAndRemovedEncoding() throws {
        let rejected = try ServerMessage.claimRejected(reason: .taken).jsonData()
        let rejectedObject = try XCTUnwrap(JSONSerialization.jsonObject(with: rejected) as? [String: Any])
        XCTAssertEqual(rejectedObject["type"] as? String, "claimRejected")
        XCTAssertEqual((rejectedObject["payload"] as? [String: Any])?["reason"] as? String, "taken")

        let removed = try ServerMessage.removed.jsonData()
        let removedObject = try XCTUnwrap(JSONSerialization.jsonObject(with: removed) as? [String: Any])
        XCTAssertEqual(removedObject["type"] as? String, "removed")
        XCTAssertNil(removedObject["payload"])
    }
}
