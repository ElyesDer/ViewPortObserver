// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ViewPortObserver",
    platforms: [
        SupportedPlatform.iOS(
            SupportedPlatform.IOSVersion.v13
        ),
        SupportedPlatform.macOS(.v10_15),
        SupportedPlatform.watchOS(
            SupportedPlatform.WatchOSVersion.v9
        ),
        SupportedPlatform.visionOS(
            SupportedPlatform.VisionOSVersion.v1
        ),
        SupportedPlatform.tvOS(
            SupportedPlatform.TVOSVersion.v12
        )
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ViewPortObserver",
            targets: ["ViewPortObserver"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ViewPortObserver"),

    ]
)
