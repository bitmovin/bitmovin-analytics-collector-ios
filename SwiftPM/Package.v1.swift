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
            name: "BitmovinAnalyticsCollector",
            targets: ["BitmovinAnalyticsCollector"]),
    ],
    dependencies: [
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BitmovinAnalyticsCollector",
            dependencies: [],
            path: "BitmovinAnalyticsCollector/Classes/",
           exclude: ["BitmovinPlayer/", "BitmovinPlayerV3/"],
            sources: ["AVPlayer/", "Collector/"]),
        .testTarget(
            name: "BitmovinAnalyticsCollectorTests",
            dependencies: ["BitmovinAnalyticsCollector"],
            path: "BitmovinAnalyticsCollector/Tests/",
            exclude: ["BitmovinPlayerTests/", "BitmovinPlayerV3Tests/"],
            sources:["AVPlayerTests/", "CoreTests/"]),
    ]
)
