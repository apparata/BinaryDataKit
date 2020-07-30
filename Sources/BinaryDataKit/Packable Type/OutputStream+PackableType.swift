//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

public extension OutputStream {
    
    /// Example:
    /// ```
    /// let stream = OutputStream.outputStreamToMemory()
    /// stream.open()
    /// stream.writeValue(Int32(1337))
    /// stream.close()
    /// let data = stream.propertyForKey(NSStreamDataWrittenToMemoryStreamKey) as! Data
    /// ```
    func writeValue<T: PackableType>(_ value: T) {
        var buffer = value.pack()
        write(&buffer, maxLength: buffer.count)
    }

    func writeValues<T: PackableType>(_ values: [T]) {
        for value in values {
            writeValue(value)
        }
    }
    
    func writeString(_ string: String) {
        let bytes: [UInt8] = Array(string.utf8)
        writeValues(bytes)
    }
}
