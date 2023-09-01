# Bitmovin Analytics Collector

Instruments adaptive streaming video players and collects information to be sent to the Bitmovin Analytics service.

To get started collecting data with Bitmovin Analytics you need a License-Key which you can get for free by signing up for a [free Bitmovin account](https://bitmovin.com/dashboard/signup).

## Supported Platforms

- iOS 14.0+
- tvOS 14.0+

## Supported Video Players

- [Bitmovin Player](https://github.com/bitmovin/bitmovin-player-ios-sdk-cocoapod)
- AVPlayer
- [Amazon IVS](https://docs.aws.amazon.com/ivs/latest/userguide/player-ios.html)

## Example

### Integrated Analytics within Bitmovin Player

We recommend to use the integrated Analytics that comes with the Bitmovin Player for iOS and tvOS SDK.
Since Analytics is directly integrated in the Player, usage is simplified compared to the standalone collector.
Please check out the [Getting Started](https://developer.bitmovin.com/playback/docs/getting-started-ios) guide.

### Collector for Amazon IVS and AVPlayer

The following example creates a AnalyticsConfig object and attaches an AVPlayer instance to it.

```swift
// Create a AnalyticsConfig using your Bitmovin analytics license key
let config: AnalyticsConfig = AnalyticsConfig(licenseKey:"YOUR_ANALYTICS_KEY")

// Create a AVPlayerCollector object using the config just created (for Amazon IVS use AmazonIVSPlayerCollectorFactory)
let analyticsCollector = AVPlayerCollectorFactory.create(config: config);

// Attach your player instance
analyticsCollector.attach(to: player);

// Detach your player when you are done.
analyticsCollector.detach()
```

### Additional Metadata (Optional)
Provide information for every session during the collector lifetime with `DefaultMetadata`
```swift
let customData = CustomData(
  customData1: "customData1"
)
let defaultMetadata = DefaultMetadata(
  cdnProvider: CdnProvider.akamai,
  customerUserId: "customUserId",
  customData: customData
)
let config: AnalyticsConfig = AnalyticsConfig(
  licenseKey: "YOUR_ANALYTICS_KEY",
  defaultMetadata: defaultMetadata
)

```

Provide video specific information with `SourceMetadata`
```swift 
let sourceMetadata = SourceMetadata(
  videoId: "video-123",
  tile: "my Video",
  isLive: false,
  customData: customData
)

// For AVPlayerCollector and AmazonIVSCollector
analyticsCollector.sourceMetadata = sourceMetadata
```

A full example app can be seen [here](https://github.com/bitmovin/bitmovin-analytics-collector-ios-samples).

## Installation

To add the `BitmovinAnalyticsCollector` as a dependency to your project, you have two options: Using CocoaPods or Swift Package Manager.
We provide our collector for platform `iOS: 14.0+` and `tvOS: 14.0+`

## Using [Swift Package Manager](https://swift.org/package-manager/)

Swift Package Manager is a tool for managing the distribution of Swift frameworks. It integrates with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

Swift Package Manager support since `2.8.0`

We provide three products:
- `BitmovinCollector` including BitmovinPlayer v3 Collector
- `AVFoundationCollector` including AVPlayer Collector
- `AmazonIVSCollector` including Amazon IVS Player Collector

### Using Xcode

To integrate using Xcode 13, open your Project file and specify it in Project > Package Dependencies using the following URL:

```
https://github.com/bitmovin/bitmovin-analytics-collector-ios
```
### Using `Package.swift`

To integrate using Apple's Swift Package Manager, add the following as a dependency to your `Package.swift` and replace `Version Number` with the desired version of the SDK.
```
.package(name: "BitmovinAnalytics", url: "https://github.com/bitmovin/bitmovin-analytics-collector-ios", .exact("Version Number"))
```
And then specify the `BitmovinAnalytics` as a dependency of the desired target. Here is an example of a `Package.swift` file:
```
let package = Package(
  ...
  dependencies: [
    ...
    .package(name: "BitmovinAnalytics", url: "https://github.com/bitmovin/bitmovin-analytics-collector-ios", .exact("Version Number"))
  ],
  targets: [
    .target(
      name: "<NAME_OF_YOUR_PACKAGE>",
      dependencies: [
        .product(name: "BitmovinCollector", package: "BitmovinAnalytics"),
        .product(name: "AVFoundationCollector", package: "BitmovinAnalytics")
        .product(name: "AmazonIVSCollector", package: "BitmovinAnalytics")
      ]),
  ]
  ...
)
```
### Limitation
Executing `swift build` from the command line is currently not supported. Open the Package in Xcode if you are developing another Package depending on `BitmovinAnalytics`.

### Import BitmovinAnalyticsCollector into your Code

We have split the `BitmovinAnalytics` into 4 targets
- CoreCollector - including shared code for all collectors
- BitmovinCollector - including `BitmovinPlayer` Collector
- AVFoundationCollector - including `AVPlayer` Collector
- AmazonIVSCollector - including `AmazonIVSPlayer` Collector

if you are working with our Collectors you need to add at least `import CoreCollector` as many Classes are relocated to that package

Going further you need to import the corresponding Collector package for player

Example when using BitmovinPlayer
```
import CoreCollector
import BitmovinCollector
```

## Using [CocoaPods](https://cocoapods.org/)

We depend on `cocoapods` version `>= 1.12.1`.
To install it, check which Player/version you are using and add the following lines to your Podfile:

### Bitmovin Player v3

The collector for the Bitmovin Player has a dependency on [BitmovinPlayerCore](https://github.com/bitmovin/player-ios-core.git) version `>= 3.41.1`.

```ruby
source 'https://github.com/bitmovin/cocoapod-specs.git'
pod 'BitmovinAnalyticsCollector/Core', '3.1.1'
pod 'BitmovinAnalyticsCollector/BitmovinPlayer', '3.1.1'
pod 'BitmovinPlayer', '3.44.0'

use_frameworks!
```

### AVPlayer

```ruby
source 'https://github.com/bitmovin/cocoapod-specs.git'
pod 'BitmovinAnalyticsCollector/Core', '3.1.1'
pod 'BitmovinAnalyticsCollector/AVPlayer', '3.1.1'

use_frameworks!
```

### AmazonIVSPlayer

The collector for the Amazon IVS Player has a dependency on `AmazonIVSPlayer` version `1.20.0`.

```ruby
source 'https://github.com/bitmovin/cocoapod-specs.git'
pod 'BitmovinAnalyticsCollector/Core', '3.1.1'
pod 'BitmovinAnalyticsCollector/AmazonIVSPlayer', '3.1.1'
pod 'AmazonIVSPlayer', '1.20.0'

use_frameworks!
```

Then, in your command line run

```ruby
pod install
```

## Known Issues

- The `audioCodec` property is not collected at the moment, as the information isn't available in the player.
- `subtitleLanguage` will fallback to the `label`, if no language is defined.

## Support
If you have any questions or issues with this Analytics Collector or its examples, or you require other technical support for our services, please login to your Bitmovin Dashboard at https://bitmovin.com/dashboard and create a new support case. Our team will get back to you as soon as possible 👍
