// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "BinaryDataKit",
    platforms: [
        .iOS(.v14), .macOS(.v12), .tvOS(.v14), .visionOS(.v1)
    ],
    products: [
        .library(name: "BinaryDataKit", targets: ["BinaryDataKit"])
    ],
    targets: [
        .target(
            name: "BinaryDataKit",
            dependencies: [],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .define("SWIFT_PACKAGE")
            ]),
        .testTarget(name: "BinaryDataKitTests", dependencies: ["BinaryDataKit"]),
    ]
)
