// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ks-db",
    platforms: [
      .iOS(.v13),
      .macOS(.v13),
      .tvOS(.v13),
      .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ks-db",
            targets: ["ks-db"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swipentap/swift-tca-appl.git", from: "1.0.2"),
        .package(url: "https://github.com/groue/GRDB.swift.git", branch: "master"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.57.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies. 7
        .target(
            name: "ks-db",
            dependencies: [
                .product(name: "Appl", package: "swift-tca-appl"),
                .product(name: "GRDB", package: "grdb.swift"),
            ],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLintPlugins"
                )
            ]
        ),
        .testTarget(
            name: "ks-dbTests",
            dependencies: ["ks-db"]
        ),
    ]
)


    
