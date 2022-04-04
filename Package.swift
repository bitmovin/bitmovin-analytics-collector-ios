// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinAnalytics",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BitmovinPlayerCollector",
            targets: ["BitmovinPlayerCollector"]),
         .library(
             name: "AVPlayerCollector",
             targets: ["AVPlayerCollector"]),
    ],
    dependencies: [
        .package(name: "BitmovinPlayer", url: "git@github.com:bitmovin/player-ios.git", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CoreCollector",
            path: "BitmovinAnalyticsCollector/Classes/",
            exclude: ["BitmovinPlayer/", "BitmovinPlayerV3/", "AVPlayer/", "AVPlayerV2/", "Collector/Info.plist"],
            sources: ["Collector/"]),
         .target(
             name: "AVPlayerCollector",
             dependencies: ["CoreCollector"],
             path: "BitmovinAnalyticsCollector/Classes/",
             exclude: ["BitmovinPlayer/", "BitmovinPlayerV3/", "Collector/", "AVPlayer/"],
             sources: ["AVPlayerV2/"]),
        .target(
            name: "BitmovinPlayerCollector",
            dependencies: ["BitmovinPlayer", "CoreCollector"],
            path: "BitmovinAnalyticsCollector/Classes/",
            exclude: ["BitmovinPlayer/", "AVPlayer/", "Collector/", "AVPlayerV2/"],
            sources: ["BitmovinPlayerV3/"]),
        
       .testTarget(
           name: "CoreCollectorTests",
           dependencies: ["CoreCollector"],
           path: "BitmovinAnalyticsCollector/Tests/",
           exclude: ["BitmovinPlayerTests/", "AVPlayerTests/", "BitmovinPlayerV3Tests/", "AVPlayerV2Tests/"],
           sources:["CoreTests/"]),
       .testTarget(
           name: "BitmovinPlayerCollectorTests",
           dependencies: ["BitmovinPlayerCollector", "BitmovinPlayer"],
           path: "BitmovinAnalyticsCollector/Tests/",
           exclude: ["BitmovinPlayerTests/", "AVPlayerTests/", "CoreTests/", "AVPlayerV2Tests/"],
           sources:["BitmovinPlayerV3Tests/"]),
        .testTarget(
            name: "AVPlayerCollectorTests",
            dependencies: ["AVPlayerCollector"],
            path: "BitmovinAnalyticsCollector/Tests/",
            exclude: ["BitmovinPlayerTests/", "BitmovinPlayerV3Tests/", "CoreTests/", "AVPlayerTests/"],
            sources:["AVPlayerV2Tests/"]),
    ]
)
