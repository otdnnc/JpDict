// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JpDict",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "JpDict",
            targets: ["JpDict"]
        ),
        .executable(
            name: "jpdict-prepare",
            targets: ["jpdict-prepare"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.10.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "JpDict",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
        ),
        .executableTarget(
            name: "jpdict-prepare",
            dependencies: [
                "JpDict",
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .testTarget(
            name: "JpDictTests",
            dependencies: ["JpDict"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
