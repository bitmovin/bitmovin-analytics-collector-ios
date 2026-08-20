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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.1-rc.1/CoreCollector.zip",
            checksum: "e258f12f1b818d2ac2a8a218f6b3472acfb3dfeefa51b7f39c6ff14dc674a73e"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.1-rc.1/AVFoundationCollector.zip",
            checksum: "417a867bc0693ab598c3730cb4e1e84d38e1737b771292a7beaa16cb76c969cd"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.1-rc.1/BitmovinCollector.zip",
            checksum: "9131a311b969fd3652ebc5b28655eeedae2cde839b9035d7eda2db8ba0793bc1"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.1-rc.1/THEOplayerCollector.zip",
            checksum: "76861753f27d5b1d8deaf0d624b4eebc6e1058cca361a89b66cd4480b2ef9aa9"
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
