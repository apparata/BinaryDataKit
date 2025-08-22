//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

extension Data {

    /// Converts the contents of this `Data` instance into a hexadecimal string.
    ///
    /// Returns `nil` if the data is empty.
    ///
    /// - Returns: A string containing the hexadecimal representation of the data,
    ///            or `nil` if the data is empty.
    ///            
    public func toHex() -> String? {
        guard !isEmpty else {
            return nil
        }
        return self.map { String(format: "%02x", $0) }.joined()
    }
}

extension NSData {

    /// Converts the contents of this `NSData` instance into a hexadecimal string.
    ///
    /// Returns `nil` if the data is empty.
    ///
    /// - Returns: A string containing the hexadecimal representation of the data,
    ///            or `nil` if the data is empty.
    ///
    public func toHex() -> String? {
        guard length > 0 else {
            return nil
        }
        var array = [UInt8]()
        for i in 0..<length {
            let byte = bytes.load(fromByteOffset: i, as: UInt8.self)
            array.append(byte)
        }
        let hexString = NSMutableString()
        for i in 0..<length {
            hexString.appendFormat(String(format: "%02x", array[i]) as NSString)
        }
        return hexString as String
    }
}
