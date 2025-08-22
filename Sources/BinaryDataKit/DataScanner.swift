//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

// MARK: - DataScanner

/// A class that scans binary data sequentially with support for endianness and type-safe reads.
open class DataScanner {

    /// Specifies the byte order (endianness) of the data.
    public enum Endianness {
        /// Little-endian byte order.
        case little
        /// Big-endian byte order.
        case big
    }

    /// Errors that can occur during scanning.
    public enum Error: Swift.Error {
        /// The requested read is out of the data bounds.
        case outOfRange
        /// The scanned data could not be converted to a valid string.
        case notValidString
        /// The scanned value did not match the required value.
        case requiredValueDoesNotMatch
    }

    /// The source binary data to scan.
    public let data: Data

    /// The current offset in the data being scanned.
    public var position: Int

    private let isHostEndian: Bool

    // MARK: - Init

    /// Initializes a new `DataScanner` with the given data, endianness, and start position.
    ///
    /// - Parameters:
    ///   - data: The binary data to scan.
    ///   - endianness: The byte order of the data. Defaults to `.little`.
    ///   - startPosition: The initial position offset in the data. Defaults to 0.
    ///
    public init(data: Data, endianness: Endianness = .little, startPosition: Int = 0) {
        self.data = data
        position = startPosition

        if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
            isHostEndian = endianness == .little
        } else {
            isHostEndian = endianness == .big
        }
    }

    // MARK: - Non-endianed

    /// Scans a value of type `T` from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned value of type `T`.
    ///
    public final func scanValue<T>() throws -> T {
        let length = MemoryLayout<T>.size
        let value: T = try scanValue(length: length)
        return value
    }

    /// Scans an array of values of type `T` from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned values of type `T`.
    ///
    public final func scanValues<T>(_ count: Int) throws -> [T] {
        var values: [T] = []
        let elementSize = MemoryLayout<T>.size
        for _ in 0..<count {
            values.append(try scanValue(length: elementSize))
        }
        return values
    }

    /// Scans a value of type `T` of a specified byte length from the current position.
    ///
    /// - Parameter length: The number of bytes to read.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned value of type `T`.
    ///
    public final func scanValue<T>(length: Int) throws -> T {
        let data = try scanData(length: length)
        let value: T = data.withUnsafeBytes { $0.load(as: T.self) }
        return value
    }

    /// Scans a value of type `T` and verifies it matches the required value.
    ///
    /// - Parameter value: The required value to match.
    /// - Throws: `Error.requiredValueDoesNotMatch` if the scanned value does not match.
    ///
    public final func scanValue<T: Equatable>(_ value: T) throws {
        let scannedValue: T = try scanValue()
        guard value == scannedValue else {
            throw Error.requiredValueDoesNotMatch
        }
    }

    // MARK: - Endianed

    /// Scans a value of type `T` from the current position, taking endianness into account.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned value of type `T`.
    ///
    public final func scanEndianedValue<T>() throws -> T {
        let length = MemoryLayout<T>.size
        let value: T = try scanEndianedValue(length: length)
        return value
    }

    /// Scans an array of values of type `T` from the current position, taking endianness into account.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned values of type `T`.
    ///
    public final func scanEndianedValues<T>(_ count: Int) throws -> [T] {
        var values: [T] = []
        let elementSize = MemoryLayout<T>.size
        for _ in 0..<count {
            values.append(try scanEndianedValue(length: elementSize))
        }
        return values
    }

    /// Scans a value of type `T` of a specified byte length from the current position, taking endianness into account.
    ///
    /// - Parameter length: The number of bytes to read.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned value of type `T`.
    ///
    public final func scanEndianedValue<T>(length: Int) throws -> T {
        let rawData = try scanData(length: length)
        let data: Data
        if isHostEndian {
            data = rawData
        } else {
            data = Data(rawData.reversed())
        }
        let value: T = data.withUnsafeBytes { $0.load(as: T.self) }
        return value
    }

    /// Scans a value of type `T` with endianness consideration and verifies it matches the required value.
    ///
    /// - Parameter value: The required value to match.
    /// - Throws: `Error.requiredValueDoesNotMatch` if the scanned value does not match.
    ///
    public final func scanEndianedValue<T: Equatable>(_ value: T) throws {
        let scannedValue: T = try scanEndianedValue()
        guard value == scannedValue else {
            throw Error.requiredValueDoesNotMatch
        }
    }

    // MARK: - Scanning explicit types

    /// Scans raw data of the specified length from the current position.
    ///
    /// - Parameter length: The number of bytes to read.
    /// - Throws: `Error.outOfRange` if the requested range is out of bounds.
    /// - Returns: The scanned `Data`.
    ///
    @discardableResult
    public final func scanData(length: Int) throws -> Data {
        guard position >= 0, length > 0, position + length <= data.count else {
            throw Error.outOfRange
        }
        let start: Int = position
        let end: Int = position + length
        position += length
        return data.subdata(in: start..<end)
    }

    /// Scans a string of the specified length and encoding from the current position.
    ///
    /// - Parameters:
    ///   - length: The number of bytes to read.
    ///   - encoding: The string encoding to use. Defaults to `.utf8`.
    ///   - nullTerminated: Whether the string is null-terminated within the length. Defaults to `false`.
    /// - Throws: `Error.outOfRange` if the requested range is out of bounds.
    /// - Throws: `Error.notValidString` if the data cannot be decoded into a valid string.
    /// - Returns: The scanned string.
    ///
    @discardableResult
    public final func scanString(length: Int, encoding: String.Encoding = .utf8, nullTerminated: Bool = false) throws -> String {
        var data = try scanData(length: length)
        if nullTerminated {
            data = data.prefix(while: { byte in
                byte != 0
            })
        }
        guard let string = String(data: data, encoding: encoding) else {
            throw Error.notValidString
        }
        return string
    }

    /// Scans a string and verifies it matches the required string.
    ///
    /// - Parameters:
    ///   - string: The required string to match.
    ///   - encoding: The string encoding to use. Defaults to `.utf8`.
    ///   - nullTerminated: Whether the string is null-terminated within the length. Defaults to `false`.
    /// - Throws: `Error.requiredValueDoesNotMatch` if the scanned string does not match.
    ///
    public final func scanString(_ string: String, encoding: String.Encoding = .utf8, nullTerminated: Bool = false) throws {
        let length = string.count + (nullTerminated ? 1 : 0)
        let scannedString = try scanString(length: length, encoding: encoding, nullTerminated: nullTerminated)
        guard scannedString == string else {
            throw Error.requiredValueDoesNotMatch
        }
    }

    /// Scans an `Int8` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `Int8` value.
    ///
    @discardableResult
    public func scanInt8() throws -> Int8 {
        return try scanEndianedValue()
    }

    /// Scans an `Int16` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `Int16` value.
    ///
    @discardableResult
    public func scanInt16() throws -> Int16 {
        return try scanEndianedValue()
    }

    /// Scans an `Int32` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `Int32` value.
    ///
    @discardableResult
    public func scanInt32() throws -> Int32 {
        return try scanEndianedValue()
    }

    /// Scans an `Int64` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `Int64` value.
    ///
    @discardableResult
    public func scanInt64() throws -> Int64 {
        return try scanEndianedValue()
    }

    /// Scans a `UInt8` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `UInt8` value.
    @discardableResult
    public func scanUInt8() throws -> UInt8 {
        return try scanEndianedValue()
    }

    /// Scans a `UInt16` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `UInt16` value.
    ///
    @discardableResult
    public func scanUInt16() throws -> UInt16 {
        return try scanEndianedValue()
    }

    /// Scans a `UInt32` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `UInt32` value.
    ///
    @discardableResult
    public func scanUInt32() throws -> UInt32 {
        return try scanEndianedValue()
    }

    /// Scans a `UInt64` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `UInt64` value.
    ///
    @discardableResult
    public func scanUInt64() throws -> UInt64 {
        return try scanEndianedValue()
    }

    /// Scans a `Float16` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `Float16` value.
    ///
    @discardableResult
    public func scanFloat16() throws -> Float16 {
        return try scanEndianedValue()
    }

    /// Scans a `Float32` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `Float32` value.
    ///
    @discardableResult
    public func scanFloat32() throws -> Float32 {
        return try scanEndianedValue()
    }

    /// Scans a `Float64` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `Float64` value.
    ///
    @discardableResult
    public func scanFloat64() throws -> Float64 {
        return try scanEndianedValue()
    }

    /// Scans an `Int` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `Int` value.
    ///
    /// - Note: Be careful, the size of `Int` depends on the CPU architecture.
    ///
    @discardableResult
    public func scanInt() throws -> Int {
        return try scanEndianedValue()
    }

    /// Scans a `UInt` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `UInt` value.
    ///
    /// - Note: Be careful, the size of `UInt` depends on the CPU architecture.
    ///
    @discardableResult
    public func scanUInt() throws -> UInt {
        return try scanEndianedValue()
    }

    /// Scans a `Float` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `Float` value.
    ///
    /// - Note: Be careful, the size of `Float` depends on the CPU architecture.
    ///
    @discardableResult
    public func scanFloat() throws -> Float {
        return try scanEndianedValue()
    }

    /// Scans a `Double` value from the current position.
    ///
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: The scanned `Double` value.
    ///
    /// - Note: Be careful, the size of `Double` depends on the CPU architecture.
    ///
    @discardableResult
    public func scanDouble() throws -> Double {
        return try scanEndianedValue()
    }

    /// Scans an array of `Int8` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `Int8` values.
    ///
    @discardableResult
    public func scanInt8Array(count: Int) throws -> [Int8] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `Int16` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `Int16` values.
    ///
    @discardableResult
    public func scanInt16Array(count: Int) throws -> [Int16] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `Int32` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `Int32` values.
    ///
    @discardableResult
    public func scanInt32Array(count: Int) throws -> [Int32] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `Int64` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `Int64` values.
    ///
    @discardableResult
    public func scanInt64Array(count: Int) throws -> [Int64] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `UInt8` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `UInt8` values.
    ///
    @discardableResult
    public func scanUInt8Array(count: Int) throws -> [UInt8] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `UInt16` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `UInt16` values.
    ///
    @discardableResult
    public func scanUInt16Array(count: Int) throws -> [UInt16] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `UInt32` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `UInt32` values.
    ///
    @discardableResult
    public func scanUInt32Array(count: Int) throws -> [UInt32] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `UInt64` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `UInt64` values.
    ///
    @discardableResult
    public func scanUInt64Array(count: Int) throws -> [UInt64] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `Float32` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `Float32` values.
    ///
    @discardableResult
    public func scanFloat32Array(count: Int) throws -> [Float32] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `Float64` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `Float64` values.
    ///
    @discardableResult
    public func scanFloat64Array(count: Int) throws -> [Float64] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `Int` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `Int` values.
    ///
    /// - Note: Be careful, the size of `Int` depends on the CPU architecture.
    ///
    @discardableResult
    public func scanIntArray(count: Int) throws -> [Int] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `UInt` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `UInt` values.
    ///
    /// - Note: Be careful, the size of `UInt` depends on the CPU architecture.
    ///
    @discardableResult
    public func scanUIntArray(count: Int) throws -> [UInt] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `Float` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `Float` values.
    ///
    /// - Note: Be careful, the size of `Float` depends on the CPU architecture.
    ///
    @discardableResult
    public func scanFloatArray(count: Int) throws -> [Float] {
        return try scanEndianedValues(count)
    }

    /// Scans an array of `Double` values from the current position.
    ///
    /// - Parameter count: The number of values to scan.
    /// - Throws: `Error.outOfRange` if there is not enough data to read.
    /// - Returns: An array of scanned `Double` values.
    ///
    /// - Note: Be careful, the size of `Double` depends on the CPU architecture.
    ///
    @discardableResult
    public func scanDoubleArray(count: Int) throws -> [Double] {
        return try scanEndianedValues(count)
    }
}
