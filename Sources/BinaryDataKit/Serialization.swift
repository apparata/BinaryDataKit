//
//  Copyright © 2020 Apparata AB. All rights reserved.
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
