//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

extension InputStream {

    /// Reads a value of the specified `PackableType` from the input stream.
    ///
    /// This function reads the exact number of bytes required to represent the type `T` from the stream,
    /// unpacks the bytes into the type `T`, and returns the value.
    ///
    /// - Returns: A value of type `T` read from the stream.
    ///
    /// - Note: Ensure that the stream is open before calling this method and closed afterwards.
    ///
    /// Example:
    /// ```
    /// let stream = InputStream(data: data)
    /// stream.open()
    /// let value: Int32 = stream.readValue()
    /// stream.close()
    /// ```
    ///
    public func readValue<T: PackableType>() -> T {
        var buffer = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
        read(&buffer, maxLength: buffer.count)
        let value = T.unpack(buffer)
        return value
    }

    /// Reads a string of the specified length from the input stream.
    ///
    /// - Parameter length: The number of bytes to read from the stream.
    /// - Returns: A string constructed from the bytes read from the stream. If the length is zero
    ///            or no valid UTF-8 string can be formed, returns an empty string.
    ///
    /// - Note: The string is expected to be UTF-8 encoded and null-terminated.
    ///
    public func readString(length: Int) -> String {
        var string = ""

        if length > 0 {
            let readBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: length + 1)
            let bytesReadCount = self.read(readBuffer, maxLength: length)
            if bytesReadCount >= 0 {
                readBuffer[bytesReadCount] = 0
                readBuffer.withMemoryRebound(to: CChar.self, capacity: bytesReadCount * MemoryLayout<CChar>.size) {
                    if let utf8String = String.init(validatingUTF8: $0) {
                        string = utf8String
                    }
                }
            }
            readBuffer.deallocate()
        }
        return string
    }
}
