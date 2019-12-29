//
//  Copyright © 2016 Apparata AB. All rights reserved.
//

import Foundation

// TODO: Implement for Data as well.

public extension NSData {
    
    private func toHex() -> String? {
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
