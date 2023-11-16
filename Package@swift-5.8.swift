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
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "CoreCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.1/CoreCollector.zip",
            checksum: "581eb82f56f4f6781ac160ae50a06529f5785a670d05874132f5474ac4f64549"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.1/AVFoundationCollector.zip",
            checksum: "eb7c50ef9b03fc85b0d7c5dc04b419febd0284d2d2afcb11d11767f5b1929510"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.1/BitmovinCollector.zip",
            checksum: "c7a8fcf29efaee884c1e22a7b9f6992d16139f39006246d82822b8b5e1b9d1e5"
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
            checksum: "9882281c7f97782be688c7f4acc5202a5f9ce3ee415d729dfd7c857351403015"
        ),
        .binaryTarget(
            name: "AmazonIVSCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.3.0-rc.1/AmazonIVSCollector.zip",
            checksum: "1b151648e9dc2d1c7f03daabfb68366870b83d4fb36316918fa39bb1036cc194"
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
