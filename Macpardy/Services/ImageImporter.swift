//
//  ImageImporter.swift
//  Macpardy
//

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Turns a user-picked image into the bytes stored on a question.
///
/// Limits:
/// - Accepted formats: PNG, JPEG, HEIC/HEIF, GIF (first frame), TIFF, BMP, WebP.
///   The type is checked from the file's contents, not its extension.
/// - Source files over 25 MB are rejected.
/// - Images are downscaled so the longest side is at most 1920 px (the display
///   is 1080p), then re-encoded: PNG if the image has transparency, otherwise
///   JPEG at 85% quality. Re-encoding also drops metadata such as GPS location.
nonisolated enum ImageImporter {

    static let maxSourceBytes = 25 * 1024 * 1024

    static let maxPixelDimension = 1920

    static let jpegQuality = 0.85

    static let acceptedTypes: [UTType] = [
        .png, .jpeg, .heic, .heif, .gif, .tiff, .bmp, .webP,
    ]

    enum ImportError: Error, Equatable {
        case fileTooLarge
        case unsupportedFormat
        case unreadable
    }

    struct Output: Equatable {
        let data: Data
        let fileExtension: String
    }

    /// Validates, downscales and re-encodes raw image bytes.
    static func importImage(data: Data) throws -> Output {
        guard data.count <= maxSourceBytes else { throw ImportError.fileTooLarge }

        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let typeIdentifier = CGImageSourceGetType(source) as String?,
              let type = UTType(typeIdentifier) else {
            throw ImportError.unsupportedFormat
        }
        guard acceptedTypes.contains(where: { type.conforms(to: $0) }) else {
            throw ImportError.unsupportedFormat
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelDimension,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw ImportError.unreadable
        }

        let output = try encode(image)
        return output
    }

    /// Reads and imports an image file the user picked.
    static func importImage(at url: URL) throws -> Output {
        let hasScopedAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasScopedAccess { url.stopAccessingSecurityScopedResource() }
        }

        let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        guard size <= maxSourceBytes else { throw ImportError.fileTooLarge }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ImportError.unreadable
        }
        return try importImage(data: data)
    }

    /// Whether the bytes decode as an image. Used to show a placeholder for
    /// corrupt images instead of failing to load the board.
    static func isDecodable(_ data: Data) -> Bool {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              CGImageSourceGetCount(source) > 0 else { return false }
        return CGImageSourceCreateImageAtIndex(source, 0, nil) != nil
    }

    /// File extension matching the bytes, used for paths inside a package.
    static func fileExtension(for data: Data) -> String {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let identifier = CGImageSourceGetType(source) as String?,
              let ext = UTType(identifier)?.preferredFilenameExtension else {
            return "img"
        }
        return ext
    }

    private static func encode(_ image: CGImage) throws -> Output {
        let hasAlpha: Bool
        switch image.alphaInfo {
        case .none, .noneSkipFirst, .noneSkipLast:
            hasAlpha = false
        default:
            hasAlpha = true
        }

        let type: UTType = hasAlpha ? .png : .jpeg
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output as CFMutableData,
            type.identifier as CFString,
            1,
            nil
        ) else {
            throw ImportError.unreadable
        }

        let properties: [CFString: Any] = hasAlpha
            ? [:]
            : [kCGImageDestinationLossyCompressionQuality: jpegQuality]
        CGImageDestinationAddImage(destination, image, properties as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw ImportError.unreadable }

        return Output(data: output as Data, fileExtension: hasAlpha ? "png" : "jpg")
    }
}
