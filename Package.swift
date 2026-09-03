// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinAnalytics",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.2/CoreCollector.zip",
            checksum: "f1f457f480ff1e07c52ded905fcb739ce33af895a34a37e8f423f3d472052a8c"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.2/AVFoundationCollector.zip",
            checksum: "baef8a819f92091a2c15b983596ced4c23b1d1a343aa5176572c2cd19655cdcf"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.2/THEOplayerCollector.zip",
            checksum: "fffcf8e49e710ef3f6f2ebd6f43c049b355960188b8c510bf710f8d2ff1886f3"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.27.2/BitmovinCollector.zip",
            checksum: "697963411fddf54d052a26e9cebcdc3729cdddbc88b8fcf63abf71709a419809"
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
