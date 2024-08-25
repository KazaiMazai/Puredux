// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Puredux",
    platforms: [
       .iOS(.v13),
       .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Puredux",
            targets: ["Puredux"]),
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
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ])
    ]
)
