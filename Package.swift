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
            targets: ["BitmovinPlayerCollectorTarget"]
        ),
        .library(
            name: "AVPlayerCollector",
            targets: ["AVPlayerCollectorTarget"]
        ),
        .library(
            name: "AmazonIVSPlayerCollector",
            targets: ["AmazonIVSPlayerCollectorTarget"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/bitmovin/player-ios-core.git", from: "3.38.1-a.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "CoreCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.23/CoreCollector.zip",
            checksum: "56906fe01b00edf52a81c4042951cb9f434e5489e927f70d62ab9dd14d15fecf"
        ),
        .binaryTarget(
            name: "AVPlayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.23/AVPlayerCollector.zip",
            checksum: "2d9670b7bc4321ae57c2523cefd445edb13713ba1d097b395031de78eae9d8f2"
        ),
        .target(
            name: "AVPlayerCollectorTarget",
            dependencies: [
                "CoreCollector",
                "AVPlayerCollector",
            ]
        ),
        .binaryTarget(
            name: "BitmovinPlayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.23/BitmovinPlayerCollector.zip",
            checksum: "41df20d25efdd9001fb393b09b1e07ed7e10e26191d36e5ac03890d56d2ed911"
        ),
        .target(
            name: "BitmovinPlayerCollectorTarget",
            dependencies: [
                "CoreCollector",
                "BitmovinPlayerCollector",
                .product(name: "BitmovinPlayerCore", package: "player-ios-core"),
            ]
        ),
        .binaryTarget(
            name: "AmazonIVSPlayer",
            url: "https://player.live-video.net/1.18.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "1b50c62c49f2ceb6eb78c276d798fe6fdfa41b8982f8ad369eebe14bfacbdb5f"
        ),
        .binaryTarget(
            name: "AmazonIVSPlayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.23/AmazonIVSPlayerCollector.zip",
            checksum: "1ca16bb8ba7ee951e644ab46d84643ef5a7f13a03c93e3cabc6406e41285521c"
        ),
        .target(
            name: "AmazonIVSPlayerCollectorTarget",
            dependencies: [
                .target(name: "AmazonIVSPlayerCollector", condition: .when(platforms: [.iOS])),
                .target(name: "AmazonIVSPlayer", condition: .when(platforms: [.iOS])),
                .target(name: "CoreCollector", condition: .when(platforms: [.iOS])),
            ]
        ),
    ]
)
