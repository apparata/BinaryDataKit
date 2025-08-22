//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

/// Converts an array of raw bytes into a value of the specified type.
///
/// - Parameters:
///   - bytes: An array of `UInt8` representing the raw bytes.
///   - asType: The type to convert the bytes into.
/// - Returns: A value of the specified type constructed from the raw bytes.
///
/// - Note: This function assumes the bytes are correctly aligned and of the correct size
///         for the specified type. Using it otherwise may lead to undefined behavior.
///
public func deserialize<T>(bytes: [UInt8], asType: T.Type) -> T {
    return bytes.withUnsafeBufferPointer {
        UnsafeRawPointer($0.baseAddress!).load(as: T.self)
    }
}

/// Converts a value into its raw byte representation as an array of `UInt8`.
///
/// - Parameter value: The value to serialize.
/// - Returns: An array of `UInt8` representing the raw bytes of the value.
///
public func serialize<T>(value: T) -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
    bytes.withUnsafeMutableBufferPointer {
        UnsafeMutableRawPointer($0.baseAddress!).storeBytes(of: value, as: T.self)
    }
    return bytes
}
