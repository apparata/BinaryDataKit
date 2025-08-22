//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

/// Scans Interchange File Format (IFF) containers and chunks.
///
/// This scanner provides functionality for parsing IFF files, including reading chunk identifiers and sizes.
/// Inherits all general scanning behavior from ``DataScanner``.
///
open class IFFScanner: DataScanner {

    /// Initializes an IFFScanner with the given data, endianness, and starting position.
    ///
    /// - Parameters:
    /// - data: The data buffer to scan.
    /// - endianness: The endianness to use for reading multi-byte values.
    ///            IFF files commonly use big-endian, and the default is `.big`.
    /// - startPosition: The initial position in the data buffer to start scanning from.
    ///
    public override init(data: Data, endianness: Endianness = .big, startPosition: Int = 0) {
        super.init(data: data, endianness: endianness, startPosition: startPosition)
    }

    /// Scans a 4-byte ASCII chunk identifier from the current position.
    ///
    /// - Returns: The scanned chunk ID as a `String`.
    /// - Throws: ``DataScanner/Error/outOfRange`` if there is not enough data,
    ///           or ``DataScanner/Error/notValidString`` if the bytes do not form a valid ASCII string.
    ///
    @discardableResult
    public func scanChunkID() throws -> String {
        return try scanString(length: 4, encoding: .ascii)
    }

    /// Scans a chunk ID from the current position and validates it matches the required string.
    ///
    /// - Parameter chunkID: The expected chunk ID string.
    /// - Throws: ``DataScanner/Error/requiredValueDoesNotMatch`` if the scanned
    ///           chunk ID does not match the required value.
    ///
    public func scanChunkID(_ chunkID: String) throws {
        try scanString(chunkID)
    }

    /// Scans a 32-bit signed integer chunk size from the current position and returns it as an `Int`.
    ///
    /// - Returns: The scanned chunk size as an `Int`.
    /// - Throws: ``DataScanner/Error/outOfRange`` if there is not enough data to read the size.
    ///
    @discardableResult
    public func scanChunkSize() throws -> Int {
        return Int(try scanInt32())
    }

    /// Scans a 32-bit chunk size from the current position and validates it equals the provided size.
    ///
    /// - Parameter size: The expected chunk size.
    /// - Throws: ``DataScanner/Error/requiredValueDoesNotMatch`` if the scanned
    ///           size does not match the required value.
    ///
    public func scanChunkSize(_ size: Int) throws {
        try scanEndianedValue(Int32(size))
    }
}
