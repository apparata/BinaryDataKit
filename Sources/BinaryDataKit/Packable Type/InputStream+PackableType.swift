//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

public extension InputStream {
    
    /// Example:
    /// ```
    /// let stream = InputStream(data: data)
    /// stream.open()
    /// let value: Int32 = stream.readValue()
    /// stream.close()
    /// ```
    func readValue<T: PackableType>() -> T {
        var buffer = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
        read(&buffer, maxLength: buffer.count)
        let value = T.unpack(buffer)
        return value
    }
    
    func readString(length: Int) -> String {
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
