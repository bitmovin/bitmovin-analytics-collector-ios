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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.2.2-a.1/CoreCollector.zip",
            checksum: "049f3d3863491364fa0a1fa01f0f46ac93b01321fc01d91f81aa0d250201090d"
        ),
        .binaryTarget(
            name: "AVFoundationCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.2.2-a.1/AVFoundationCollector.zip",
            checksum: "04656a546e29e626f4064590fefd585a644589e28ffb0e2a0cf8fe4a50e323fc"
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
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.2.2-a.1/BitmovinCollector.zip",
            checksum: "00a8acc7132355ec92dce4345ea6375088a01f6d30274bce1c991e55a4b5e77f"
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
            url: "https://player.live-video.net/1.22.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "f1bf63e42d742318c948d25c5bc5cc1df1d03ebc0760d4d77431fd07dea94657"
        ),
        .binaryTarget(
            name: "AmazonIVSCollector",
            url: "https://cdn.bitmovin.com/analytics/ios_tvos/3.2.2-a.1/AmazonIVSCollector.zip",
            checksum: "4187a52c2cf1fa8a2396bbf970c829f971256d199e0c1856a710a7c4e52532a1"
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
