// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PureduxUIKit",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "PureduxUIKit",
            targets: ["PureduxUIKit"])
    ],
    dependencies: [
        .package(name: "PureduxStore",
                 url: "https://github.com/KazaiMazai/PureduxStore.git", from: "1.0.0"),
       
        .package(name: "PureduxCommon",
                 url: "https://github.com/KazaiMazai/PureduxCommon.git", from: "1.0.0")

    ],
    targets: [
        .target(
            name: "PureduxUIKit",
            dependencies: [
                .product(name: "PureduxStore", package: "PureduxStore"),
                .product(name: "PureduxCommon", package: "PureduxCommon")
            ]),
        .testTarget(
            name: "PureduxUIKitTests",
            dependencies: ["PureduxUIKit"])
    ]
)
