// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinAnalytics",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BitmovinPlayerCollector",
            targets: ["BitmovinPlayerCollectorWrapper"]
        ),
        .library(
            name: "AVPlayerCollector",
            targets: ["AVPlayerCollectorWrapper"]
        ),
        .library(
            name: "AmazonIVSPlayerCollector",
            targets: ["AmazonIVSPlayerCollectorWrapper"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/bitmovin/player-ios.git", from: "3.35.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "CoreCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/x.x.x/CoreCollector.zip",
            checksum: "CoreCollector-hash"
        ),
        .binaryTarget(
            name: "AVPlayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/x.x.x/AVPlayerCollector.zip",
            checksum: "AVPlayerCollector-hash"
        ),
        .target(
            name: "AVPlayerCollectorWrapper",
            dependencies: [
                "CoreCollector",
                "AVPlayerCollector",
            ]
        ),
        .binaryTarget(
            name: "BitmovinPlayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/x.x.x/BitmovinPlayerCollector.zip",
            checksum: "BitmovinPlayerCollector-hash"
        ),
        .target(
            name: "BitmovinPlayerCollectorWrapper",
            dependencies: [
                "CoreCollector",
                "BitmovinPlayerCollector",
                .product(name: "BitmovinPlayer", package: "player-ios"),
            ]
        ),
        .binaryTarget(
            name: "AmazonIVSPlayer",
            url: "https://player.live-video.net/1.18.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "1b50c62c49f2ceb6eb78c276d798fe6fdfa41b8982f8ad369eebe14bfacbdb5f"
        ),
        .binaryTarget(
            name: "AmazonIVSPlayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/x.x.x/AmazonIVSPlayerCollector.zip",
            checksum: "AmazonIVSPlayerCollector-hash"
        ),
        .target(
            name: "AmazonIVSPlayerCollectorWrapper",
            dependencies: [
                .target(name: "AmazonIVSPlayerCollector", condition: .when(platforms: [.iOS])),
                .target(name: "AmazonIVSPlayer", condition: .when(platforms: [.iOS])),
                .target(name: "CoreCollector", condition: .when(platforms: [.iOS])),
            ]
        ),
    ]
)
