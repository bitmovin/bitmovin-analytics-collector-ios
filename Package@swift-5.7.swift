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
        .package(url: "https://github.com/bitmovin/player-ios-core.git", from: "3.51.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "CoreCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.4.0-rc.1/CoreCollector.zip",
            checksum: "7a2e9c4df6475347b2530a4f7142c9041977274c255f340620ee8005564618e1"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.4.0-rc.1/AVFoundationCollector.zip",
            checksum: "b1f64c7b028873f27e6e40f45c6b09ca1c1d448389609e9563fcbab7b2df1050"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.4.0-rc.1/BitmovinCollector.zip",
            checksum: "644d598c8366b8e7175550e9afc8698e0257e48114e4e262d9181a23bb924d86"
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
            url: "https://player.live-video.net/1.23.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "b9306d68a659a88900c06c9f9a895f9828850fdbdd52488daf25d89a4552352a"
        ),
        .binaryTarget(
            name: "AmazonIVSCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.4.0-rc.1/AmazonIVSCollector.zip",
            checksum: "b3132b9611beea7ea2aa220942f7571a109c1d77c7f0c874918dbc74f0b15ed2"
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
