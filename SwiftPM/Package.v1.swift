// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinAnalyticsCollector",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BitmovinAnalyticsCollectorAVPlayer",
            targets: ["BitmovinAnalyticsCollectorCore", "BitmovinAnalyticsCollectorAVPlayer"]),
    ],
    dependencies: [],
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
            name: "BitmovinAnalyticsCollectorAVPlayer",
            path: "BitmovinAnalyticsCollector/Classes/",
            exclude: ["BitmovinPlayer/", "BitmovinPlayerV3/", "Collector/"],
            sources:["AVPlayer/"]),
        .testTarget(
            name: "BitmovinAnalyticsCollectorCoreTests",
            dependencies: ["BitmovinAnalyticsCollectorCore"],
            path: "BitmovinAnalyticsCollector/Tests/",
            exclude: ["BitmovinPlayerTests/", "AVPlayerTests/", "BitmovinPlayerV3Tests/"],
            sources:["CoreTests/"]),
        .testTarget(
            name: "BitmovinAnalyticsCollectorAVPlayerTests",
            dependencies: ["BitmovinAnalyticsCollectorAVPlayer"],
            path: "BitmovinAnalyticsCollector/Tests/",
            exclude: ["BitmovinPlayerTests/", "BitmovinPlayerV3Tests/", "CoreTests/"],
            sources:["AVPlayerTests/"]),
    ]
)
