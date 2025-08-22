# BinaryDataKit

A Swift package for efficient binary data scanning, parsing, and serialization with support for endianness-aware operations and specialized file format handling.

## Overview

BinaryDataKit provides type-safe, performant tools for working with binary data in Swift. It includes:

- **DataScanner**: Sequential binary data scanning with endianness support
- **IFFScanner**: Specialized scanner for Interchange File Format (IFF) containers
- **PackableType Protocol**: Easy serialization/deserialization for Swift types
- **Data Extensions**: Convenient methods for direct data value extraction

## Features

- ✅ Type-safe binary data scanning with automatic endianness handling
- ✅ Support for all Swift numeric types (Int8-64, UInt8-64, Float16/32/64)
- ✅ String scanning with configurable encoding and null-termination
- ✅ Array scanning for efficient bulk data reading
- ✅ IFF file format support with chunk ID and size parsing
- ✅ Protocol-based serialization system
- ✅ Direct Data extensions for value extraction
- ✅ Comprehensive error handling
- ✅ Cross-platform support (iOS 14+, macOS 12+, tvOS 14+, visionOS 1+)

## Installation

### Swift Package Manager

Add BinaryDataKit to your project by adding the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/BinaryDataKit.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies...
2. Enter the package URL
3. Click Add Package

## Quick Start

### Basic Data Scanning

Scanning moves the scanning position.

```swift
import BinaryDataKit

let data = Data([0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0])
let scanner = DataScanner(data: data, endianness: .little)

// Scan individual values
let byte: UInt8 = try scanner.scanUInt8()     // 0x12
let word: UInt16 = try scanner.scanUInt16()   // 0x5634 (little-endian)
let dword: UInt32 = try scanner.scanUInt32()  // 0xDEBC9A78

// Scan arrays
scanner.position = 0
let bytes = try scanner.scanUInt8Array(count: 4)  // [0x12, 0x34, 0x56, 0x78]
```

### String Scanning

```swift
let textData = "Hello\0World".data(using: .utf8)!
let scanner = DataScanner(data: textData)

// Scan null-terminated string
let greeting = try scanner.scanString(length: 6, nullTerminated: true)  // "Hello"

// Scan fixed-length string
let remaining = try scanner.scanString(length: 5)  // "World"
```

### IFF File Format

```swift
let iffData = // ... your IFF file data
let scanner = IFFScanner(data: iffData)  // Defaults to big-endian

// Read chunk header
let chunkID = try scanner.scanChunkID()    // e.g., "FORM"
let chunkSize = try scanner.scanChunkSize() // Size in bytes

// Validate specific chunk
try scanner.scanChunkID("ILBM")  // Throws if not matched
try scanner.scanChunkSize(expectedSize)
```

### Serialization with PackableType

```swift
import BinaryDataKit

// All numeric types conform to PackableType by default
let value: Int32 = 0x12345678
let bytes = value.pack()  // [0x78, 0x56, 0x34, 0x12] on little-endian
let restored = Int32.unpack(bytes)  // 0x12345678

// Custom types
struct Point: PackableType {
    let x: Float32
    let y: Float32
}

let point = Point(x: 1.0, y: 2.0)
let pointBytes = point.pack()
let restoredPoint = Point.unpack(pointBytes)
```

### Direct Data Access

```swift
let data = Data([0x12, 0x34, 0x56, 0x78])

// Extract values directly
let value16: UInt16 = data.scanValue(start: 0)  // 0x3412
let value32: UInt32 = data.scanValue(start: 0)  // 0x78563412

// Extract arrays
let bytes: [UInt8] = data.scanValues(start: 0, count: 4)
```

## API Reference

### DataScanner

The main class for sequential binary data scanning:

#### Initialization
```swift
DataScanner(data: Data, endianness: .little/.big, startPosition: Int = 0)
```

#### Core Methods
- `scanValue<T>() throws -> T` - Scan any type
- `scanValues<T>(_ count: Int) throws -> [T]` - Scan array of values
- `scanData(length: Int) throws -> Data` - Scan raw data
- `scanString(length: Int, encoding: .utf8, nullTerminated: Bool) throws -> String`

#### Numeric Types
- `scanInt8/16/32/64() throws -> IntN`
- `scanUInt8/16/32/64() throws -> UIntN`  
- `scanFloat16/32/64() throws -> FloatN`
- Array versions: `scanInt8Array(count:)`, etc.

#### Endianness
- All `scanEndianedValue` methods respect the scanner's endianness setting
- Non-endianed methods read data as-is

### IFFScanner

Extends DataScanner for IFF file format:

```swift
IFFScanner(data: Data, endianness: .big, startPosition: Int = 0)
scanChunkID() throws -> String
scanChunkSize() throws -> Int
```

### PackableType Protocol

```swift
protocol PackableType {
    func pack() -> [UInt8]
    static func unpack(_ bytes: [UInt8]) -> Self
}
```

Built-in conformance for: `Int`, `Int8-64`, `UInt`, `UInt8-64`, `Float`, `Double`

## Error Handling

BinaryDataKit defines specific error types:

```swift
DataScanner.Error.outOfRange                // Read beyond data bounds
DataScanner.Error.notValidString            // Invalid string encoding
DataScanner.Error.requiredValueDoesNotMatch // Value validation failed
```

## Platform Support

- iOS 14.0+
- macOS 12.0+
- tvOS 14.0+
- visionOS 1.0+
- Swift 5.10+

## License

BinaryDataKit is available under the BSD Zero Clause License. See [LICENSE](LICENSE) for details.
