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
            name: "BitmovinPlayerCollectorSDK",
            targets: [
                "CoreCollector",
                "BitmovinPlayerCollector",
                "BitmovinPlayerTarget"
            ]
        ),
        .library(
            name: "BitmovinPlayerCollector",
            targets: [
                "BitmovinPlayerCollector",
            ]
        ),
        .library(
            name: "AVPlayerCollectorSDK",
            targets: [
                "CoreCollector",
                "AVPlayerCollector",
            ]
        ),
        .library(
            name: "AmazonIVSPlayerCollectorSDK",
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.22/CoreCollector.zip",
            checksum: "a7ee2f0876151d244a42a66741b6d02493a15dce71ffce42ae5a35e09f64de8f"
        ),
        .binaryTarget(
            name: "AVPlayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.22/AVPlayerCollector.zip",
            checksum: "21fc1d16d62840ff6366b0e9ded4dfea008b0fdefe2ea432b8f383453393b65f"
        ),
        .binaryTarget(
            name: "BitmovinPlayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.22/BitmovinPlayerCollector.zip",
            checksum: "2aba931347078089146f602ce3c15e8def6d1d948c0860948fbd9a6f4281b97c"
        ),
        .target(
            name: "BitmovinPlayerTarget",
            dependencies: [
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/2.11.1-a.22/AmazonIVSPlayerCollector.zip",
            checksum: "59ea9c12448c3d0d4127b48da1d640951b28aa897b31b1caccb5d6cb460c39c5"
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
