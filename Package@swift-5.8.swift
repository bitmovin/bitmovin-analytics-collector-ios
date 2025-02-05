// swift-tools-version:5.8
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.12.0-a.1/CoreCollector.zip",
            checksum: "676258795e5835ef435bbc95da0a92fc00c7a6fdbcaf4daffc62107969310796"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.12.0-a.1/AVFoundationCollector.zip",
            checksum: "d53c3f19aba6117fe0e52f25f498d1321efa02af499e8e7e1601757528ec7930"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.12.0-a.1/BitmovinCollector.zip",
            checksum: "8f6c88c30f235ad4090b97ce4abe7e15ae975ae5704c5a24a1d863437ce352f3"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.12.0-a.1/AmazonIVSCollector.zip",
            checksum: "1a2263e51891b7b88c98ce5c3f64ab0fbbc605cd44ba72e2fe3de0da20c78b41"
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
