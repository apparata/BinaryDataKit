//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

public extension Data {
    
    func scanValue<T>(start: Int) -> T {
        return scanValue(start: start, length: MemoryLayout<T>.size)
    }
    
    func scanValues<T>(start: Int, count: Int) -> [T] {
        var values: [T] = []
        let elementSize = MemoryLayout<T>.size
        for i in stride(from: start, to: start + count * elementSize, by: elementSize) {
            values.append(scanValue(start: i, length: elementSize))
        }
        return values
    }
    
    func scanValue<T>(start: Int, length: Int) -> T {
        return subdata(in: start..<start+length).withUnsafeBytes { $0.load(as: T.self) }
    }
}

open class DataScanner {
    
    public enum Endianness {
        case little
        case big
    }
    
    public enum Error: Swift.Error {
        case outOfRange
        case notValidString
        case requiredValueDoesNotMatch
    }
    
    public let data: Data
    
    public var position: Int
    
    private let isHostEndian: Bool
    
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
    
    public final func scanValue<T>() throws -> T {
        let length = MemoryLayout<T>.size
        let value: T = try scanValue(length: length)
        return value
    }
    
    public final func scanValues<T>(_ count: Int) throws -> [T] {
        var values: [T] = []
        let elementSize = MemoryLayout<T>.size
        for _ in 0..<count {
            values.append(try scanValue(length: elementSize))
        }
        return values
    }
    
    public final func scanValue<T>(length: Int) throws -> T {
        let data = try scanData(length: length)
        let value: T = data.withUnsafeBytes { $0.load(as: T.self) }
        return value
    }
    
    public final func scanValue<T: Equatable>(_ value: T) throws {
        let scannedValue: T = try scanValue()
        guard value == scannedValue else {
            throw Error.requiredValueDoesNotMatch
        }
    }
    
    // MARK: - Endianed
    
    public final func scanEndianedValue<T>() throws -> T {
        let length = MemoryLayout<T>.size
        let value: T = try scanEndianedValue(length: length)
        return value
    }
    
    public final func scanEndianedValues<T>(_ count: Int) throws -> [T] {
        var values: [T] = []
        let elementSize = MemoryLayout<T>.size
        for _ in 0..<count {
            values.append(try scanEndianedValue(length: elementSize))
        }
        return values
    }
    
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
    
    public final func scanEndianedValue<T: Equatable>(_ value: T) throws {
        let scannedValue: T = try scanEndianedValue()
        guard value == scannedValue else {
            throw Error.requiredValueDoesNotMatch
        }
    }
    
    // MARK: - Scanning explicit types
    
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
    
    public final func scanString(_ string: String, encoding: String.Encoding = .utf8, nullTerminated: Bool = false) throws {
        let length = string.count + (nullTerminated ? 1 : 0)
        let scannedString = try scanString(length: length, encoding: encoding, nullTerminated: nullTerminated)
        guard scannedString == string else {
            throw Error.requiredValueDoesNotMatch
        }
    }
    
    @discardableResult
    public func scanInt8() throws -> Int8 {
        return try scanEndianedValue()
    }
    
    @discardableResult
    public func scanInt16() throws -> Int16 {
        return try scanEndianedValue()
    }
    
    @discardableResult
    public func scanInt32() throws -> Int32 {
        return try scanEndianedValue()
    }
    
    @discardableResult
    public func scanInt64() throws -> Int64 {
        return try scanEndianedValue()
    }
    
    @discardableResult
    public func scanUInt8() throws -> UInt8 {
        return try scanEndianedValue()
    }
    
    @discardableResult
    public func scanUInt16() throws -> UInt16 {
        return try scanEndianedValue()
    }
    
    @discardableResult
    public func scanUInt32() throws -> UInt32 {
        return try scanEndianedValue()
    }
    
    @discardableResult
    public func scanUInt64() throws -> UInt64 {
        return try scanEndianedValue()
    }

    #if os(iOS)
    @available(iOS 14, *)
    @discardableResult
    public func scanFloat16() throws -> Float16 {
        return try scanEndianedValue()
    }
    #endif
    
    @discardableResult
    public func scanFloat32() throws -> Float32 {
        return try scanEndianedValue()
    }
    
    @discardableResult
    public func scanFloat64() throws -> Float64 {
        return try scanEndianedValue()
    }
    
    /// NOTE: Be careful, the size of Int depends on the CPU architecture.
    @discardableResult
    public func scanInt() throws -> Int {
        return try scanEndianedValue()
    }
    
    /// NOTE: Be careful, the size of UInt depends on the CPU architecture.
    @discardableResult
    public func scanUInt() throws -> UInt {
        return try scanEndianedValue()
    }
    
    /// NOTE: Be careful, the size of Float depends on the CPU architecture.
    @discardableResult
    public func scanFloat() throws -> Float {
        return try scanEndianedValue()
    }
    
    /// NOTE: Be careful, the size of Double depends on the CPU architecture.
    @discardableResult
    public func scanDouble() throws -> Double {
        return try scanEndianedValue()
    }
    
    @discardableResult
    public func scanInt8Array(count: Int) throws -> [Int8] {
        return try scanEndianedValues(count)
    }
    
    @discardableResult
    public func scanInt16Array(count: Int) throws -> [Int16] {
        return try scanEndianedValues(count)
    }
    
    @discardableResult
    public func scanInt32Array(count: Int) throws -> [Int32] {
        return try scanEndianedValues(count)
    }
    
    @discardableResult
    public func scanInt64Array(count: Int) throws -> [Int64] {
        return try scanEndianedValues(count)
    }
    
    @discardableResult
    public func scanUInt8Array(count: Int) throws -> [UInt8] {
        return try scanEndianedValues(count)
    }
    
    @discardableResult
    public func scanUInt16Array(count: Int) throws -> [UInt16] {
        return try scanEndianedValues(count)
    }
    
    @discardableResult
    public func scanUInt32Array(count: Int) throws -> [UInt32] {
        return try scanEndianedValues(count)
    }
    
    @discardableResult
    public func scanUInt64Array(count: Int) throws -> [UInt64] {
        return try scanEndianedValues(count)
    }
    
    @discardableResult
    public func scanFloat32Array(count: Int) throws -> [Float32] {
        return try scanEndianedValues(count)
    }
    
    @discardableResult
    public func scanFloat64Array(count: Int) throws -> [Float64] {
        return try scanEndianedValues(count)
    }
    
    /// NOTE: Be careful, the size of Int depends on the CPU architecture.
    @discardableResult
    public func scanIntArray(count: Int) throws -> [Int] {
        return try scanEndianedValues(count)
    }
    
    /// NOTE: Be careful, the size of UInt depends on the CPU architecture.
    @discardableResult
    public func scanUIntArray(count: Int) throws -> [UInt] {
        return try scanEndianedValues(count)
    }
    
    /// NOTE: Be careful, the size of Float depends on the CPU architecture.
    @discardableResult
    public func scanFloatArray(count: Int) throws -> [Float] {
        return try scanEndianedValues(count)
    }
    
    /// NOTE: Be careful, the size of Double depends on the CPU architecture.
    @discardableResult
    public func scanDoubleArray(count: Int) throws -> [Double] {
        return try scanEndianedValues(count)
    }
    
}

/// Interchange File Format scanner.
open class IFFScanner: DataScanner {
    
    override init(data: Data, endianness: Endianness = .big, startPosition: Int = 0) {
        super.init(data: data, endianness: endianness, startPosition: startPosition)
    }
    
    @discardableResult
    public func scanChunkID() throws -> String {
        return try scanString(length: 4, encoding: .ascii)
    }
    
    public func scanChunkID(_ chunkID: String) throws {
        try scanString(chunkID)
    }
    
    @discardableResult
    public func scanChunkSize() throws -> Int {
        return Int(try scanInt32())
    }
    
    public func scanChunkSize(_ size: Int) throws {
        try scanEndianedValue(Int32(size))
    }
}
