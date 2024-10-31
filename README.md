# BitmovinAnalyticsCollector

Instruments adaptive streaming video players and collects information to be sent to the Bitmovin Analytics service.

To get started collecting data with Bitmovin Analytics you need a license key which you can get for free by signing up for a [free Bitmovin account](https://bitmovin.com/dashboard/signup).

## Platform Support

| Version         | Platform                               | Player                              |
|-----------------|----------------------------------------|-------------------------------------|
| 3.2.0 - 3.x.x   | iOS 14+, tvOS 14+, visionOS 1+         | Bitmovin v3, AVPlayer, Amazon IVS   |
| 3.0.0 - 3.1.2   | iOS 14+, tvOS 14+                      | Bitmovin v3, AVPlayer, Amazon IVS   |
| 2.11.0 - 2.12.1 | iOS 14+, tvOS 14+                      | Bitmovin v3, AVPlayer, Amazon IVS   |
| 2.9.0 - 2.10.1  | iOS 12+, tvOS 12+                      | Bitmovin v3, AVPlayer               |
| 2.0.0 - 2.8.0   | iOS 9+, tvOS 9+                        | Bitmovin v3, AVPlayer               |
| > 1.30.0        | iOS 9+, tvOS 9+                        | Bitmovin v2, AVPlayer               |

## Example

### Integrated Analytics within Bitmovin Player

We recommend to use the integrated Analytics that comes with the Bitmovin Player for iOS, tvOS and visionOS SDK.
Since Analytics is directly integrated in the Player, usage is simplified compared to the standalone collector.

Please check out the [Getting Started](https://developer.bitmovin.com/playback/docs/getting-started-ios) guide.

### Collector for Amazon IVS and AVPlayer

The following example creates an AnalyticsConfig object and attaches an AVPlayer instance to it.

```swift
// Create a AnalyticsConfig using your Bitmovin analytics license key
let analyticsConfig = AnalyticsConfig(licenseKey: "YOUR_ANALYTICS_KEY")

// Create an AVPlayerCollector object using the config just created (for Amazon IVS use AmazonIVSPlayerCollectorFactory)
let analyticsCollector = AVPlayerCollectorFactory.create(config: analyticsConfig)

// Attach your player instance
analyticsCollector.attach(to: player)

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

To add the `BitmovinAnalyticsCollector` as a dependency to your project, you have two options: Swift Package Manager or CocoaPods.

## Swift Package Manager

Swift Package Manager is supported since version `2.8.0`.

We provide three products:
- `BitmovinCollector` including BitmovinPlayer v3 Collector
- `AVFoundationCollector` including AVPlayer Collector
- `AmazonIVSCollector` including Amazon IVS Player Collector

### Using Xcode

Open your Project file and specify it in **Project > Package Dependencies** using the following URL:

```
https://github.com/bitmovin/bitmovin-analytics-collector-ios
```

### Using Package.swift

You can also add us manually. For that you need to add the following as a dependency to your `Package.swift` and replace `<Bitmovin Analytics Version Number>` with the desired version of the SDK.

```swift
.package(name: "BitmovinAnalytics", url: "https://github.com/bitmovin/bitmovin-analytics-collector-ios", .exact("<Bitmovin Analytics Version Number>"))
```

And then specify the `BitmovinAnalytics` as a dependency of the desired target. Here is an example of a `Package.swift` file:

```swift
let package = Package(
  ...
  dependencies: [
    ...
    .package(name: "BitmovinAnalytics", url: "https://github.com/bitmovin/bitmovin-analytics-collector-ios", .exact("<Bitmovin Analytics Version Number>"))
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

⚠️ **Note:** Executing `swift build` from the command line is currently not supported. Open the Package in Xcode if you are developing another Package depending on `BitmovinAnalytics`.

### How to import the collector

We have split the `BitmovinAnalytics` into 4 targets
- CoreCollector - including shared code for all collectors
- BitmovinCollector - including `BitmovinPlayer` Collector
- AVFoundationCollector - including `AVPlayer` Collector
- AmazonIVSCollector - including `AmazonIVSPlayer` Collector

If you are working with our Collectors you need to add at least `import CoreCollector` as many Classes are relocated to that package.

Going further you need to import the corresponding Collector package for player.

Example when using BitmovinPlayer:

```swift
import CoreCollector
import BitmovinCollector
```

## CocoaPods

We depend on `cocoapods` version `>= 1.13.0`.

Add the following lines to the Podfile of your project while replacing `VERSION_NUMBER` with the desired version of the SDK.

> All available versions from **3.8.1** on can be listed via `pod trunk info BitmovinAnalyticsCollector` and are available in [CocoaPods trunk repository](https://github.com/CocoaPods/Specs/tree/master/Specs/6/1/d/BitmovinAnalyticsCollector).
> Earlier versions are listed in our [CocoaPods repository](https://github.com/bitmovin/cocoapod-specs/tree/master/Specs/BitmovinAnalyticsCollector) instead

### Bitmovin Player v3

The collector for the [Bitmovin Player](https://developer.bitmovin.com/playback/docs/getting-started-ios) has a dependency on [BitmovinPlayerCore](https://github.com/bitmovin/player-ios-core.git) version `>= 3.48`.

```ruby
pod 'BitmovinAnalyticsCollector/Core', '<Bitmovin Analytics Version Number>'
pod 'BitmovinAnalyticsCollector/BitmovinPlayer', '<Bitmovin Analytics Version Number>'
pod 'BitmovinPlayer', '<Player Version Number>'

use_frameworks!
```

### AVPlayer

```ruby
pod 'BitmovinAnalyticsCollector/Core', '<Bitmovin Analytics Version Number>'
pod 'BitmovinAnalyticsCollector/AVPlayer', '<Bitmovin Analytics Version Number>'

use_frameworks!
```

### AmazonIVSPlayer

The collector for the [Amazon IVS Player](https://docs.aws.amazon.com/ivs/latest/userguide/player-ios.html) has a dependency on `AmazonIVSPlayer` version `1.24.0`.

```ruby
pod 'BitmovinAnalyticsCollector/Core', '<Bitmovin Analytics Version Number>'
pod 'BitmovinAnalyticsCollector/AmazonIVSPlayer', '<Bitmovin Analytics Version Number>'
pod 'AmazonIVSPlayer', '<Player Version Number>'

use_frameworks!
```

Then, in your command line run

```shell
pod install
```

## Known Issues

- The `audioCodec` property is not collected at the moment, as the information isn't available in the player.
- `subtitleLanguage` will fallback to the `label`, if no language is defined.

## Support
If you have any questions or issues with this Analytics Collector or its examples, or you require other technical support for our services, please login to your Bitmovin Dashboard at https://bitmovin.com/dashboard and create a new support case. Our team will get back to you as soon as possible 👍
