// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinAnalyticsCollector",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BitmovinAnalyticsCollectorBitmovinPlayerV3",
            targets: ["BitmovinAnalyticsCollectorCore", "BitmovinAnalyticsCollectorBitmovinPlayerV3"]),
    ],
    dependencies: [
        .package(name: "BitmovinPlayer", url: "git@github.com:bitmovin/player-ios.git", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BitmovinAnalyticsCollectorCore",
            dependencies: [],
            path: "BitmovinAnalyticsCollector/Classes/",
            exclude: ["BitmovinPlayer/", "AVPlayer/", "Collector/BitmovinAnalyticsCollector.h", "Collector/Info.plist", "BitmovinPlayerV3/"],
            sources:["Collector/"]),
        .target(
            name: "BitmovinAnalyticsCollectorBitmovinPlayerV3",
            dependencies: ["BitmovinPlayer"],
            path: "BitmovinAnalyticsCollector/Classes/",
            exclude: ["BitmovinPlayer/", "AVPlayer/", "Collector/"],
            sources:["BitmovinPlayerV3/"]),
        .testTarget(
            name: "BitmovinAnalyticsCollectorCoreTests",
            dependencies: ["BitmovinAnalyticsCollectorCore"],
            path: "BitmovinAnalyticsCollector/Tests/",
            exclude: ["BitmovinPlayerTests/", "AVPlayerTests/", "BitmovinPlayerV3Tests/"],
            sources:["CoreTests/"]),
        .testTarget(
            name: "BitmovinAnalyticsCollectorBitmovinPlayerV3Tests",
            dependencies: ["BitmovinAnalyticsCollectorBitmovinPlayerV3", "BitmovinPlayer"],
            path: "BitmovinAnalyticsCollector/Tests/",
            exclude: ["BitmovinPlayerTests/", "AVPlayerTests/", "CoreTests/"],
            sources:["BitmovinPlayerV3Tests/"]),
    ]
)
