// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinAnalytics",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BitmovinPlayerCollector",
            targets: ["BitmovinPlayerCollector"]
        ),
        .library(
            name: "AVPlayerCollector",
            targets: ["AVPlayerCollector"]
        ),
    ],
    dependencies: [
        .package(name: "BitmovinPlayer", url: "https://github.com/bitmovin/player-ios.git", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CoreCollector",
            dependencies: []
        ),
        .target(
            name: "AVPlayerCollector",
            dependencies: ["CoreCollector"]
        ),
        .target(
            name: "BitmovinPlayerCollector",
            dependencies: ["BitmovinPlayer", "CoreCollector"]
        ),
        .testTarget(
            name: "CoreCollectorTests",
            dependencies: ["CoreCollector"]
        ),
        .testTarget(
            name: "BitmovinPlayerCollectorTests",
            dependencies: ["BitmovinPlayerCollector", "BitmovinPlayer"]
        ),
        .testTarget(
            name: "AVPlayerCollectorTests",
            dependencies: ["AVPlayerCollector"]
        ),
    ]
)
