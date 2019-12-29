//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

func deserialize<T>(bytes: [UInt8], asType: T.Type) -> T {
    return bytes.withUnsafeBufferPointer {
        UnsafeRawPointer($0.baseAddress!).load(as: T.self)
    }
}

func serialize<T>(value: T) -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
    bytes.withUnsafeMutableBufferPointer {
        UnsafeMutableRawPointer($0.baseAddress!).storeBytes(of: value, as: T.self)
    }
    return bytes
}

public protocol PackableType { }

public extension PackableType {
    
    func pack() -> [UInt8] {
        return serialize(value: self)
    }
    
    static func unpack(_ valueByteArray: [UInt8]) -> Self {
        return deserialize(bytes: valueByteArray, asType: Self.self)
    }
}

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

public extension Data {
    
    init(contentsOf values: [PackableType]) {
        let bytes: [UInt8] = values.flatMap { $0.pack() }
        self.init(bytes)
    }
    
    mutating func appendValues(_ values: [PackableType]) {
        let bytes: [UInt8] = values.flatMap { $0.pack() }
        append(contentsOf: bytes)
    }
}

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
}
