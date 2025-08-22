//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

extension Data {

    /// Reads a value of type `T` starting at the specified byte offset.
    ///
    /// - Parameters:
    ///   - start: The byte offset in the data to start reading from.
    /// - Returns: The value of type `T` read from the data.
    ///
    /// - Note: The data must contain enough bytes starting at `start` to read a value of type `T`.
    ///         Alignment and safety considerations apply.
    ///
    public func scanValue<T>(start: Int) -> T {
        return scanValue(start: start, length: MemoryLayout<T>.size)
    }

    /// Reads multiple consecutive values of type `T` starting at the specified offset.
    ///
    /// - Parameters:
    ///   - start: The byte offset in the data to start reading from.
    ///   - count: The number of values to read.
    /// - Returns: An array of values of type `T` read from the data.
    ///
    /// - Note: The data must contain enough bytes starting at `start` to read `count` values
    ///         of type `T`. Alignment and safety considerations apply.
    ///
    public func scanValues<T>(start: Int, count: Int) -> [T] {
        var values: [T] = []
        let elementSize = MemoryLayout<T>.size
        for i in stride(from: start, to: start + count * elementSize, by: elementSize) {
            values.append(scanValue(start: i, length: elementSize))
        }
        return values
    }

    /// Reads a value of type `T` from a specific range of bytes, defined by offset and length.
    ///
    /// - Parameters:
    ///   - start: The byte offset in the data to start reading from.
    ///   - length: The number of bytes to read.
    /// - Returns: The value of type `T` read from the specified range of bytes.
    ///
    /// - Note: The data must contain enough bytes in the specified range to read a value
    ///         of type `T`. Alignment and safety considerations apply.
    ///
    public func scanValue<T>(start: Int, length: Int) -> T {
        return subdata(in: start..<start+length).withUnsafeBytes { $0.load(as: T.self) }
    }
}
