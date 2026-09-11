// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinAnalytics",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
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
            name: "THEOplayerCollector",
            targets: ["THEOplayerCollectorTarget"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/bitmovin/player-ios-core.git", from: "3.51.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "CoreCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.28.0-rc.1/CoreCollector.zip",
            checksum: "f72b4696fafc40a4e54a88ecd5a9de1b33ee598d83ce410d0343d5333ce855ea"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.28.0-rc.1/AVFoundationCollector.zip",
            checksum: "634e3948cf634ab16e01ff6bd84c38d600ae106116c82d386996c10bec262dd9"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.28.0-rc.1/BitmovinCollector.zip",
            checksum: "7895827d99bd4c413f65ff0e7d0e11c76f58d7854df851f90f4e71a63fac36e4"
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
            name: "THEOplayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.28.0-rc.1/THEOplayerCollector.zip",
            checksum: "d2536dc567550e658a5f5ff10f24bf762986f5226365e845004f9e0ac339fc60"
        ),
        .target(
            name: "THEOplayerCollectorTarget",
            dependencies: [
                "CoreCollector",
                "THEOplayerCollector",
            ]
        ),
    ]
)
