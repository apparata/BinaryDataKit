//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

/// A protocol that marks types that can be packed to and unpacked from raw bytes.
/// Default implementations for packing and unpacking are provided.
public protocol PackableType { }

extension PackableType {

    /// Serializes the value into its raw byte representation.
    ///
    /// - Returns: An array of bytes representing the serialized value.
    /// - Note: The byte order and layout follow the current platform's representation
    ///         used by `serialize(value:)`.
    ///
    public func pack() -> [UInt8] {
        return serialize(value: self)
    }

    /// Deserializes a value from a byte array.
    ///
    /// - Parameters:
    ///   - valueByteArray: An array of bytes representing the serialized value.
    /// - Returns: The deserialized value of the conforming type.
    /// - Note: The alignment and size of the byte array must match the original platform
    ///         used to pack the value, and the endianness must be consistent.
    ///
    public static func unpack(_ valueByteArray: [UInt8]) -> Self {
        return deserialize(bytes: valueByteArray, asType: Self.self)
    }
}

// Standard integer and floating‑point types made `PackableType` by default.
extension Int: PackableType { }
extension Int8: PackableType { }
extension Int16: PackableType { }
extension Int32: PackableType { }
extension Int64: PackableType { }
extension UInt: PackableType { }
extension UInt8: PackableType { }
extension UInt16: PackableType { }
extension UInt32: PackableType { }
extension UInt64: PackableType { }
extension Float: PackableType { }
extension Double: PackableType { }
