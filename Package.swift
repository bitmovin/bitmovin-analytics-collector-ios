// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinAnalytics",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .visionOS(.v1),
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.28.1/CoreCollector.zip",
            checksum: "73f3bdc6debbbfa4728c631fbafba91f5ebe8ef27e888f8e6a99dcc2015c81eb"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.28.1/AVFoundationCollector.zip",
            checksum: "56d065afab84dfb9d9714b709ea39b9bc34630516cd2df4a1796b2e8cbf5ce2a"
        ),
        .target(
            name: "AVFoundationCollectorTarget",
            dependencies: [
                "CoreCollector",
                "AVFoundationCollector",
            ]
        ),
        .binaryTarget(
            name: "THEOplayerCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.28.1/THEOplayerCollector.zip",
            checksum: "4aacefa3622ca664f5bc9bc7dcd9917583bfab07122586860317017c3b72af75"
        ),
        .target(
            name: "THEOplayerCollectorTarget",
            dependencies: [
                "CoreCollector",
                "THEOplayerCollector",
            ]
        ),
        .binaryTarget(
            name: "BitmovinCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.28.1/BitmovinCollector.zip",
            checksum: "403e383b4342153d1117a87bdbc39ef916d7732b60cefbfba026fd743e4b5bcd"
        ),
        .target(
            name: "BitmovinCollectorTarget",
            dependencies: [
                "CoreCollector",
                "BitmovinCollector",
                .product(name: "BitmovinPlayerCore", package: "player-ios-core"),
            ]
        ),
    ]
)
