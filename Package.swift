// swift-tools-version:5.3
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
            type: .dynamic,
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.91/CoreCollector.zip",
            checksum: "2ae3e243a46964621d66a0852f28785c46d3196c7d5571f3c080af3ab8c81fc6"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.91/AVFoundationCollector.zip",
            checksum: "c80f8b2357a7358999824311e813c734cafaf43f26d4d72470e44ff7bb2b0a54"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.91/BitmovinCollector.zip",
            checksum: "8e600726caa40ad6f658eb4fc40bd6a053858c6c9da68774bbdd653bf5f5a5cb"
        ),
        .target(
            name: "BitmovinCollectorTarget",
            dependencies: [
                "CoreCollector",
                "BitmovinCollector",
                .product(name: "BitmovinPlayerCore", package: "player-ios-core"),
            ]
        ),
        .binaryTarget(
            name: "AmazonIVSPlayer",
            url: "https://player.live-video.net/1.18.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "1b50c62c49f2ceb6eb78c276d798fe6fdfa41b8982f8ad369eebe14bfacbdb5f"
        ),
        .binaryTarget(
            name: "AmazonIVSCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.91/AmazonIVSCollector.zip",
            checksum: "f2a709fe92dd1f6efcc3d7ae90a974dd43fd4aa5c93799c0a4f5c1816e82ffc7"
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
