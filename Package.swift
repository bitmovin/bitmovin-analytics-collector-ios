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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.2/CoreCollector.zip",
            checksum: "0244439e59d1e7cb0c7217345aa0ff30a5435090934eaea84c06ebfbde416a92"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.2/AVFoundationCollector.zip",
            checksum: "011a2425cc0f8da242b53bb869baac3fba9a1e9f3c5513837dd2284266aa2f35"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.2/BitmovinCollector.zip",
            checksum: "668753c3505379c15e21aff632778473b8219d36a5a2c90a8819a8e102f7bab3"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.2/AmazonIVSCollector.zip",
            checksum: "6bda6c2186227e5f5585f5c63ddd1cdb0c5b0f13d7d6901c3d59377809ef53ce"
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
