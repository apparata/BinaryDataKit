//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

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
