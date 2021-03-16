// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PureduxSwiftUI",
    platforms: [
       .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PureduxSwiftUI",
            targets: ["PureduxSwiftUI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "PureduxStore",
                 url: "https://github.com/KazaiMazai/PureduxStore.git",
                 .exact("1.0.0-beta.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PureduxSwiftUI",
            dependencies: [
                .product(name: "PureduxStore", package: "PureduxStore"),
            ]),
        .testTarget(
            name: "PureduxSwiftUITests",
            dependencies: ["PureduxSwiftUI"]),
    ]
)
