//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

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
