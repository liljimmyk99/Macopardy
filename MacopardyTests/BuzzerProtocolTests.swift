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

    func testJoinAcceptedEncoding() throws {
        let data = try ServerMessage.joinAccepted(teamNames: ["A"]).jsonData()
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["type"] as? String, "joinAccepted")
        let payload = try XCTUnwrap(object["payload"] as? [String: Any])
        XCTAssertEqual(payload["version"] as? Int, BuzzerConstants.protocolVersion)
    }
}
