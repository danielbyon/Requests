// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Requests",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "Requests",
            targets: ["Requests"]),
    ],
    targets: [
        .target(
            name: "Requests",
            dependencies: []),
        .testTarget(
            name: "RequestsTests",
            dependencies: ["Requests"]),
    ]
)
