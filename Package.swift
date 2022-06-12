// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PureduxSwiftUI",
    platforms: [
       .iOS(.v13)
    ],
    products: [

        .library(
            name: "PureduxSwiftUI",
            targets: ["PureduxSwiftUI"])
    ],
    dependencies: [
        // The heart of Puredux
        .package(name: "PureduxStore",
                 url: "https://github.com/KazaiMazai/PureduxStore.git", .upToNextMajor(from: "1.0.0")),

        // Puredux shared utils
        .package(name: "PureduxCommon",
                 url: "https://github.com/KazaiMazai/PureduxCommon.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
       .target(
            name: "PureduxSwiftUI",
            dependencies: [
                .product(name: "PureduxStore", package: "PureduxStore"),
                .product(name: "PureduxCommon", package: "PureduxCommon")
            ]),

        .testTarget(
            name: "PureduxSwiftUITests",
            dependencies: [
                "PureduxSwiftUI"
            ])
    ]
)
