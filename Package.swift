// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PureduxStore",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "PureduxStore",
            targets: ["PureduxStore"])
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "PureduxStore",
            dependencies: []),
        .testTarget(
            name: "PureduxStoreTests",
            dependencies: ["PureduxStore"])
    ]
)
