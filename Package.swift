// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinAnalytics",
    platforms: [
        .iOS("14.2"),
        .tvOS("14.2")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BitmovinPlayerCollector",
            targets: ["BitmovinPlayerCollector"]
        ),
        .library(
            name: "AVPlayerCollector",
            targets: ["AVPlayerCollector"]
        ),
        .library(
            name: "AmazonIVSPlayerCollector",
            targets: ["AmazonIVSPlayerCollector"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/bitmovin/player-ios.git", from: "3.35.0"),
        .package(url: "https://github.com/Quick/Quick.git", exact: "5.0.1"),
        .package(url: "https://github.com/Quick/Nimble.git", exact: "10.0.0"),
        .package(url: "https://github.com/Brightify/Cuckoo.git", from: "1.9.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CoreCollector",
            dependencies: []
        ),
        .target(
            name: "AVPlayerCollector",
            dependencies: [
                "CoreCollector"
            ]
        ),
        .target(
            name: "BitmovinPlayerCollector",
            dependencies: [
                .product(name: "BitmovinPlayer", package: "player-ios"),
                "CoreCollector"
            ]
        ),
        .binaryTarget(
            name: "AmazonIVSPlayer",
            url: "https://player.live-video.net/1.17.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "bccc9ae5a02b3fb6c5535869607403609e4e9854f322052d37a8a71cef9657e6"
        ),
        .target(
            name: "AmazonIVSPlayerCollector",
            dependencies: [
                "CoreCollector",
                "AmazonIVSPlayer"
            ]
        ),
        .testTarget(
            name: "CoreCollectorTests",
            dependencies: [
                "CoreCollector",
                "Quick",
                "Nimble",
                "Cuckoo"
            ]
        ),
        .testTarget(
            name: "BitmovinPlayerCollectorTests",
            dependencies: [
                "BitmovinPlayerCollector",
                .product(name: "BitmovinPlayer", package: "player-ios"),
                "Quick",
                "Nimble",
                "Cuckoo"
            ]
        ),
        .testTarget(
            name: "AVPlayerCollectorTests",
            dependencies: [
                "AVPlayerCollector",
                "Quick",
                "Nimble",
                "Cuckoo"
            ]
        ),
        .testTarget(
            name: "AmazonIVSPlayerCollectorTests",
            dependencies: [
                "AmazonIVSPlayerCollector",
                "AmazonIVSPlayer",
                "Quick",
                "Nimble",
                "Cuckoo"
            ]
        ),
    ]
)
