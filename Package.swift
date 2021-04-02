// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Puredux",
    platforms: [
       .iOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Puredux",
            targets: ["Puredux"]),
    ],
    dependencies: [
        .package(name: "PureduxSideEffects",
                 url: "https://github.com/KazaiMazai/PureduxSideEffects.git",
                 .exact("1.0.0-beta.1")),

        .package(name: "PureduxNetworkOperator",
                 url: "https://github.com/KazaiMazai/PureduxNetworkOperator.git",
                 .exact("1.0.0-beta.1")),

        .package(name: "PureduxStore",
                 url: "https://github.com/KazaiMazai/PureduxStore.git",
                 .exact("1.0.0-beta.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Puredux",
            dependencies: [
                .product(name: "PureduxStore", package: "PureduxStore"),
                .product(name: "PureduxSideEffects", package: "PureduxSideEffects"),
                .product(name: "PureduxNetworkOperator", package: "PureduxNetworkOperator"),
            ]),
        .testTarget(
            name: "PureduxTests",
            dependencies: ["Puredux"]),
    ]
)
