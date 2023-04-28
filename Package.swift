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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.18/CoreCollector.zip",
            checksum: "ec556e988a36bc289723569c465348fc1cb7f70e6fa0b47be7031de707deda06"
        ),
        .binaryTarget(
            name: "AVPlayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.18/AVPlayerCollector.zip",
            checksum: "5bf84fbf711be7383a519499546930993f575e7bc2843a962f067731fe44c8a0"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.18/BitmovinPlayerCollector.zip",
            checksum: "8b5243144dc8237ffd701ec041ca25947bf69c5d34d8c28f2c4a7c357025ab2d"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.18/AmazonIVSPlayerCollector.zip",
            checksum: "88c1caa2e83a712729c7ef295897f11226d9f4c7edc31b9268a79400f2352ba2"
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
