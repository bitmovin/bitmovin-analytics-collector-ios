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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.0-rc.1/CoreCollector.zip",
            checksum: "6939b960d68329966ce0683293ff95e622c44570698284d8b7586d830878ac01"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.0-rc.1/AVFoundationCollector.zip",
            checksum: "730420b6fff5bfd58dbbbe936e70d944d48a6868c9a7854d89587b5602b95249"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.0-rc.1/BitmovinCollector.zip",
            checksum: "0cb04bfb4695a5848a9946df794cdb28f353f177ae6be9f14317616451f5fb4c"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.0-rc.1/THEOplayerCollector.zip",
            checksum: "33a8dda357cab891b81947ced1b4d66e399e2abf0fd1b1b96ec0d252008795fd"
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
