// swift-tools-version:5.9

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
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(name: "PureduxMacros", path: "Packages/PureduxMacros")
    ],
    targets: [
        .macro(
            name: "PureduxMacrosPlugin",
            dependencies: [
                "PureduxMacros",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
       .target(
            name: "Puredux",
            dependencies: [
                "PureduxMacros",
                "PureduxMacrosPlugin"
            ]),

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
