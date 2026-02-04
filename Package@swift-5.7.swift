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
        ),
        .library(
            name: "THEOplayerCollector",
            targets: ["THEOplayerCollectorTarget"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/bitmovin/player-ios-core.git", from: "3.51.0"),
        .package(url: "https://github.com/THEOplayer/theoplayer-sdk-apple", from: "10.7.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "CoreCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.21.0-a.10/CoreCollector.zip",
            checksum: "1e2236f73f15e8a6692f3faffae82d7710bd62194b4a729be32950d55067acc6"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.21.0-a.10/AVFoundationCollector.zip",
            checksum: "590d47c77dbb067ad789dcc9a955be0df9eb9027b6d0698f040486428e05a949"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.21.0-a.10/BitmovinCollector.zip",
            checksum: "0139bbfa9db981d546fa2f5a94e77d0f75042116b52d9fcba868d6b24d2424bb"
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
            url: "https://player.live-video.net/1.24.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "33a165cde872f0b7af6a44a33bbda91b3e15e095a7e05c392f0b30adbd8f2350"
        ),
        .binaryTarget(
            name: "AmazonIVSCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.21.0-a.10/AmazonIVSCollector.zip",
            checksum: "e586ba5adbef139c4e87bafe89b133087ad4a429085103efa986eb302a848f23"
        ),
        .target(
            name: "AmazonIVSCollectorTarget",
            dependencies: [
                .target(name: "AmazonIVSCollector", condition: .when(platforms: [.iOS])),
                .target(name: "AmazonIVSPlayer", condition: .when(platforms: [.iOS])),
                .target(name: "CoreCollector", condition: .when(platforms: [.iOS])),
            ]
        ),
        .binaryTarget(
            name: "THEOplayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.21.0-a.10/THEOplayerCollector.zip",
            checksum: "2b4ca59cee48bb61291169e2a3ba8b5b438f845ddf0e72510805ac1cb0fd6ccf"
        ),
        .target(
            name: "THEOplayerCollectorTarget",
            dependencies: [
                "CoreCollector",
                "THEOplayerCollector",
                .product(name: "THEOplayerSDK", package: "theoplayer-sdk-apple"),
            ]
        ),
    ]
)
