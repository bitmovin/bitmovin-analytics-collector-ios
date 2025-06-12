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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.12.2-rc.2/CoreCollector.zip",
            checksum: "31cf669112f8546c336749fe612225a1d6f270ddafee553000aed0a4edae1cce"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.12.2-rc.2/AVFoundationCollector.zip",
            checksum: "8a0105d483f8dfa12f825f6ecf8eb24e8467ea3e6cdd9f44c181a08da0c7745d"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.12.2-rc.2/BitmovinCollector.zip",
            checksum: "84094ac20f52cfaf4866bceb7faff4bfa13d6fb7b08f6e4aa97d565a35c069f2"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.12.2-rc.2/AmazonIVSCollector.zip",
            checksum: "30a5a55e708bd3648ecf0e93a4558abff031502a3ab13004d310378ad78ba125"
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
