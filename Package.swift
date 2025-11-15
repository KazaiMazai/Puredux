// swift-tools-version:5.10

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Puredux",
    platforms: [
       .iOS(.v13),
       .macOS(.v14),
       .tvOS(.v12),
       .watchOS(.v7)

    ],
    products: [
        .library(
            name: "Puredux",
            targets: ["Puredux"])
    ],
    dependencies: [
        .package(url: "https://github.com/KazaiMazai/Crocodil.git", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "Puredux",
            dependencies: [
                .product(name: "Crocodil", package: "Crocodil")
            ]
        ),
        .testTarget(
            name: "PureduxTests",
            dependencies: ["Puredux"]),
    ]
)
