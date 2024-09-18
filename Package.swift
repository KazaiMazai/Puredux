// swift-tools-version:5.10

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Puredux",
    platforms: [
       .iOS(.v13),
       .macOS(.v10_15),
       .tvOS(.v12),
       .watchOS(.v7)

    ],
    products: [
        .library(
            name: "Puredux",
            targets: ["Puredux"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0")
    ],
    targets: [
        .macro(
            name: "PureduxMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "Puredux",
            dependencies: [
                "PureduxMacros"
            ]
        ),
        .testTarget(
            name: "PureduxTests",
            dependencies: ["Puredux"]),

        .testTarget(
            name: "PureduxMacrosTests",
            dependencies: [
                "PureduxMacros",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ])
    ]
)
