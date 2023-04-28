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
        .package(url: "https://github.com/bitmovin/player-ios.git", from: "3.35.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "CoreCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.19/CoreCollector.zip",
            checksum: "7de6c425f75aa45a65c5ebc887d00386fa8e2a0ef33fbba35fd9d1ca8f848f81"
        ),
        .binaryTarget(
            name: "AVPlayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.19/AVPlayerCollector.zip",
            checksum: "13c9905b0af7de0f9bf80a1ea012282398a13f4cab2be6193a0f5393fcd63cb2"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.19/BitmovinPlayerCollector.zip",
            checksum: "29b265d2190de3b9f78296f4bd1acc98a975edc8987b1051fec0499a6c5c63fb"
        ),
        .target(
            name: "BitmovinPlayerCollectorTarget",
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.19/AmazonIVSPlayerCollector.zip",
            checksum: "32cf84bed1ad5d850f19f29e54cba5100d8544017dc46bcbb10ef47306fc4f94"
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
