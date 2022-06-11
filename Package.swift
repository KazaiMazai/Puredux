// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PureduxUIKit",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PureduxUIKit",
            targets: ["PureduxUIKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "PureduxStore",
                 url: "https://github.com/KazaiMazai/PureduxStore.git", from: "1.0.0"),
        .package(name: "PureduxCommon",
                 url: "https://github.com/KazaiMazai/PureduxCommon.git", from: "1.0.0")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
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
