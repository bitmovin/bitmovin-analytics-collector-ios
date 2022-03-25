// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinAnalyticsCollector",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BitmovinCollector",
            targets: ["BitmovinCollector"]),
         .library(
             name: "BitmovinCollectorAVPlayer",
             targets: ["BitmovinCollectorAVPlayer"]),
    ],
    dependencies: [
        .package(name: "BitmovinPlayer", url: "git@github.com:bitmovin/player-ios.git", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BitmovinCollectorCore",
            path: "BitmovinAnalyticsCollector/Classes/",
            exclude: ["BitmovinPlayer/", "BitmovinPlayerV3/", "AVPlayer/", "AVPlayerV2/", "Collector/Info.plist"],
            sources: ["Collector/"]),
         .target(
             name: "BitmovinCollectorAVPlayer",
             dependencies: ["BitmovinCollectorCore"],
             path: "BitmovinAnalyticsCollector/Classes/",
             exclude: ["BitmovinPlayer/", "BitmovinPlayerV3/", "Collector/", "AVPlayer/"],
             sources: ["AVPlayerV2/"]),
        .target(
            name: "BitmovinCollector",
            dependencies: ["BitmovinPlayer", "BitmovinCollectorCore"],
            path: "BitmovinAnalyticsCollector/Classes/",
            exclude: ["BitmovinPlayer/", "AVPlayer/", "Collector/", "AVPlayerV2/"],
            sources: ["BitmovinPlayerV3/"]),
       .testTarget(
           name: "BitmovinCollectorCoreTests",
           dependencies: ["BitmovinCollectorCore"],
           path: "BitmovinAnalyticsCollector/Tests/",
           exclude: ["BitmovinPlayerTests/", "AVPlayerTests/", "BitmovinPlayerV3Tests/", "AVPlayerV2Tests/"],
           sources:["CoreTests/"]),
       .testTarget(
           name: "BitmovinCollectorTests",
           dependencies: ["BitmovinCollector", "BitmovinPlayer"],
           path: "BitmovinAnalyticsCollector/Tests/",
           exclude: ["BitmovinPlayerTests/", "AVPlayerTests/", "CoreTests/", "AVPlayerV2Tests/"],
           sources:["BitmovinPlayerV3Tests/"]),
        .testTarget(
            name: "BitmovinCollectorAVPlayerTests",
            dependencies: ["BitmovinCollectorAVPlayer"],
            path: "BitmovinAnalyticsCollector/Tests/",
            exclude: ["BitmovinPlayerTests/", "BitmovinPlayerV3Tests/", "CoreTests/", "AVPlayerTests/"],
            sources:["AVPlayerV2Tests/"]),
    ]
)
