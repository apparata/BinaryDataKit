//
//  Copyright © 2020 Apparata AB. All rights reserved.
//

import Foundation

extension Data {

    /// Initializes a `Data` instance from an array of `PackableType` values by packing them into raw bytes.
    ///
    /// - Parameter values: An array of `PackableType` values to be packed into the `Data` instance.
    ///
    public init(contentsOf values: [PackableType]) {
        let bytes: [UInt8] = values.flatMap { $0.pack() }
        self.init(bytes)
    }

    /// Appends the packed byte representations of the given `PackableType` values to the existing `Data`.
    ///
    /// - Parameter values: An array of `PackableType` values whose packed bytes will be appended.
    /// 
    public mutating func appendValues(_ values: [PackableType]) {
        let bytes: [UInt8] = values.flatMap { $0.pack() }
        append(contentsOf: bytes)
    }
}
