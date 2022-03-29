// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Localize",
    platforms: [
        .macOS(SupportedPlatform.MacOSVersion.v10_12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(name: "localize", targets: ["Localize"]),
//        .library(
//            name: "Localize",
//            targets: ["Localize"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.2")),
        .package(url: "https://github.com/CoreOffice/CoreXLSX", .upToNextMajor(from: "0.14.1")),
        .package(url: "https://github.com/swiftcsv/SwiftCSV", .upToNextMajor(from: "0.6.0")),
        .package(url: "https://github.com/mxcl/Path.swift.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "4.0.6")),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "Localize",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
//                "Yams",
                "LocalizeFramework",
//                .product(name: "Path", package: "Path.swift"),
            ]),
        
        .target(
            name: "LocalizeFramework",
            dependencies: [
                "CoreXLSX",
                "SwiftCSV",
                .product(name: "Path", package: "Path.swift"),
                "Yams",
        ]),
        .testTarget(
            name: "LocalizeTests",
            dependencies: [
                "LocalizeFramework"
            ],
            resources: [
                .copy("Resource")
            ]
        ),
    ]
)
