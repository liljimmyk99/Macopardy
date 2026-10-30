//
//  ImageImporterTests.swift
//  MacpardyTests
//

import UniformTypeIdentifiers
import XCTest
@testable import Macpardy

@MainActor
final class ImageImporterTests: XCTestCase {

    func testSmallImageKeepsItsSize() throws {
        let output = try ImageImporter.importImage(data: TestImages.make(width: 300, height: 200))
        let size = try XCTUnwrap(TestImages.pixelSize(of: output.data))
        XCTAssertEqual(size.width, 300)
        XCTAssertEqual(size.height, 200)
    }

    func testLargeImageIsDownscaledToMaxDimension() throws {
        let output = try ImageImporter.importImage(data: TestImages.make(width: 4000, height: 1000))
        let size = try XCTUnwrap(TestImages.pixelSize(of: output.data))
        XCTAssertEqual(size.width, ImageImporter.maxPixelDimension)
        XCTAssertEqual(size.height, 480)
    }

    func testOpaqueImageIsReencodedAsJPEG() throws {
        let output = try ImageImporter.importImage(data: TestImages.make(width: 50, height: 50, opaque: true, type: .jpeg))
        XCTAssertEqual(output.fileExtension, "jpg")
        XCTAssertEqual(TestImages.typeIdentifier(of: output.data), UTType.jpeg.identifier)
    }

    func testTransparentImageStaysPNG() throws {
        let output = try ImageImporter.importImage(data: TestImages.make(width: 50, height: 50, opaque: false))
        XCTAssertEqual(output.fileExtension, "png")
        XCTAssertEqual(TestImages.typeIdentifier(of: output.data), UTType.png.identifier)
    }

    func testNonImageDataIsRejected() {
        XCTAssertThrowsError(try ImageImporter.importImage(data: Data("not an image".utf8))) { error in
            XCTAssertEqual(error as? ImageImporter.ImportError, .unsupportedFormat)
        }
    }

    func testOversizedSourceIsRejected() {
        let tooBig = Data(count: ImageImporter.maxSourceBytes + 1)
        XCTAssertThrowsError(try ImageImporter.importImage(data: tooBig)) { error in
            XCTAssertEqual(error as? ImageImporter.ImportError, .fileTooLarge)
        }
    }

    func testOversizedFileIsRejectedBeforeReading() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
        FileManager.default.createFile(atPath: url.path, contents: nil)
        let handle = try FileHandle(forWritingTo: url)
        try handle.truncate(atOffset: UInt64(ImageImporter.maxSourceBytes + 1))
        try handle.close()
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertThrowsError(try ImageImporter.importImage(at: url)) { error in
            XCTAssertEqual(error as? ImageImporter.ImportError, .fileTooLarge)
        }
    }

    func testIsDecodable() {
        XCTAssertTrue(ImageImporter.isDecodable(TestImages.make(width: 10, height: 10)))
        XCTAssertFalse(ImageImporter.isDecodable(Data("garbage".utf8)))
        XCTAssertFalse(ImageImporter.isDecodable(Data()))
    }
}
