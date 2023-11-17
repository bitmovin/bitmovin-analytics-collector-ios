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
            name: "AmazonIVSCollector",
            targets: ["AmazonIVSCollectorTarget"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "CoreCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.3/CoreCollector.zip",
            checksum: "1fca292f66bf1703acbf57952aaaeb0a28d09673e9374b4c22f898fca9c7602c"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.3/AVFoundationCollector.zip",
            checksum: "7098f7b06f0f132516cc136fda6efe0fe291f3409fdd91593370683eb8810a5b"
        ),
        .target(
            name: "AVFoundationCollectorTarget",
            dependencies: [
                "CoreCollector",
                "AVFoundationCollector",
            ],
            path: "spm/public/Sources/AVFoundationCollectorTarget"
        ),
        .binaryTarget(
            name: "BitmovinCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.3/BitmovinCollector.zip",
            checksum: "cf986f356780923e016f66c7151a1c3894067a79623cc363d455df77258ebfef"
        ),
        .target(
            name: "BitmovinCollectorTarget",
            dependencies: [
                "CoreCollector",
                "BitmovinCollector"
            ],
            path: "spm/public/Sources/BitmovinCollectorTarget"
        ),
        .binaryTarget(
            name: "AmazonIVSPlayer",
            url: "https://player.live-video.net/1.23.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "b9306d68a659a88900c06c9f9a895f9828850fdbdd52488daf25d89a4552352a"
        ),
        .binaryTarget(
            name: "AmazonIVSCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.3/AmazonIVSCollector.zip",
            checksum: "8624857b89845f82d1dd8ba842f119d5b36ca0a7d7b8717a29e59fba129b5ea7"
        ),
        .target(
            name: "AmazonIVSCollectorTarget",
            dependencies: [
                "CoreCollector",
                .target(name: "AmazonIVSCollector", condition: .when(platforms: [.iOS])),
            ],
            path: "spm/public/Sources/AmazonIVSCollectorTarget"
        ),
    ]
)
