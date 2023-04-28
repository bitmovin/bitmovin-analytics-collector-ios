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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.20/CoreCollector.zip",
            checksum: "1c837bcde901142c05b5de52e4105ea08e3b68fda7f0256ac0641f58a6e2436f"
        ),
        .binaryTarget(
            name: "AVPlayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.20/AVPlayerCollector.zip",
            checksum: "81bfaaa8a0f8518b41e132465a18f84547339b585ef828dc429d6b8c370b69cf"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.20/BitmovinPlayerCollector.zip",
            checksum: "0219332379a41f2c71d8a7ef57fe4991f22563900769ed33d0cd20fd949423b8"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.20/AmazonIVSPlayerCollector.zip",
            checksum: "81d8cff9a1acb1b471a589e499ab97bbe7e6042c4b758a090c358e6632d7fa9e"
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
