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
            name: "BitmovinCollector",
            targets: ["BitmovinCollectorTarget"]
        ),
        .library(
            name: "AVFoundationCollector",
            targets: ["AVFoundationCollectorTarget"]
        ),
        .library(
            name: "AmazonIVSCollector",
            targets: ["AmazonIVSCollectorTarget"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/bitmovin/player-ios-core.git", from: "3.39.0-a.16"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "CoreCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.84/CoreCollector.zip",
            checksum: "d337f33bc4f14d3462d758f63dbf6671cc6ebdaad08501ee156d39c190e1ebc5"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.84/AVFoundationCollector.zip",
            checksum: "eb22c4c0fda11a1ac747386ea9ed016d0739da70dd96ab3f708ac4b3ad5d13e8"
        ),
        .target(
            name: "AVFoundationCollectorTarget",
            dependencies: [
                "CoreCollector",
                "AVFoundationCollector",
            ]
        ),
        .binaryTarget(
            name: "BitmovinCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.84/BitmovinCollector.zip",
            checksum: "ca5f2e7d61997da93f946702de4c12ba872d0e3ab4161a9d3e400915ffefb495"
        ),
        .target(
            name: "BitmovinCollectorTarget",
            dependencies: [
                "CoreCollector",
                "BitmovinCollector",
                .product(name: "BitmovinPlayer", package: "player-ios"),
            ]
        ),
        .binaryTarget(
            name: "AmazonIVSPlayer",
            url: "https://player.live-video.net/1.18.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "1b50c62c49f2ceb6eb78c276d798fe6fdfa41b8982f8ad369eebe14bfacbdb5f"
        ),
        .binaryTarget(
            name: "AmazonIVSCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.84/AmazonIVSCollector.zip",
            checksum: "1d7274b1cbff1b236002926e9b791d65cc75d769f44ab2dd56ad876d3f71de34"
        ),
        .target(
            name: "AmazonIVSCollectorTarget",
            dependencies: [
                .target(name: "AmazonIVSCollector", condition: .when(platforms: [.iOS])),
                .target(name: "AmazonIVSPlayer", condition: .when(platforms: [.iOS])),
                .target(name: "CoreCollector", condition: .when(platforms: [.iOS])),
            ]
        ),
    ]
)
