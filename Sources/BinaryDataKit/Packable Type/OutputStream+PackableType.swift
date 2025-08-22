//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

extension OutputStream {

    /// Writes a single `PackableType` value to the stream.
    ///
    /// - Parameter value: The `PackableType` value to write.
    ///
    /// - Note: The stream must be open before calling this method and closed afterwards.
    ///
    /// ### Example
    ///
    /// ```
    /// let stream = OutputStream.outputStreamToMemory()
    /// stream.open()
    /// stream.writeValue(Int32(1337))
    /// stream.close()
    /// let data = stream.propertyForKey(NSStreamDataWrittenToMemoryStreamKey) as! Data
    /// ```
    ///
    public func writeValue<T: PackableType>(_ value: T) {
        var buffer = value.pack()
        write(&buffer, maxLength: buffer.count)
    }

    /// Writes an array of `PackableType` values to the stream.
    ///
    /// - Parameter values: The array of `PackableType` values to write.
    ///
    /// - Note: The stream must be open before calling this method and closed afterwards.
    ///
    public func writeValues<T: PackableType>(_ values: [T]) {
        for value in values {
            writeValue(value)
        }
    }

    /// Writes the UTF-8 bytes of a string to the stream.
    ///
    /// - Parameter string: The string whose UTF-8 bytes will be written.
    ///
    /// - Note: No null terminator is written, only the raw UTF-8 bytes.
    ///         The stream must be open before calling this method.
    ///
    public func writeString(_ string: String) {
        let bytes: [UInt8] = Array(string.utf8)
        writeValues(bytes)
    }
}
