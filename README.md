# BitmovinAnalyticsCollector

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

The following example creates a BitmovinAnalytics object and attaches an AVPlayer instance to it.

```swift
// Create a BitmovinAnalyticsConfig using your Bitmovin analytics license key and/or your Bitmovin Player Key
let config:BitmovinAnalyticsConfig = BitmovinAnalyticsConfig(key:"YOUR_ANALYTICS_KEY",playerKey:"YOUR_PLAYER_KEY")
let config:BitmovinAnalyticsConfig = BitmovinAnalyticsConfig(key:"YOUR_ANALYTICS_KEY")

// Create a AVPlayerCollector object using the config just created (for the Bitmovin Player, create a BitmovinPlayerCollector)
analyticsCollector = AVPlayerCollector(config: config);

// Attach your player instance
analyticsCollector.attachPlayer(player: player);

// Detach your player when you are done.
analyticsCollector.detachPlayer()
```

### Optional Configuration Parameters

```swift
config.cdnProvider = CdnProvider.akamai
config.customData1 = "customData1"
config.customData2 = "customData2"
config.customData3 = "customData3"
config.customData4 = "customData4"
config.customData5 = "customData5"
config.customerUserId = "customUserId"
config.experimentName = "experiement-1"
config.videoId = "iOSHLSStatic"
config.path = "/vod/breadcrumb/"
config.isLive = true
config.ads = true
```

A full example app can be seen [here](https://github.com/bitmovin/bitmovin-analytics-collector-ios/tree/main/CollectorDemoApp).

## Installation

To add the `BitmovinAnalyticsCollector` as a dependency to your project, you have two options: Using CocoaPods or Swift Package Manager.
We provide our collector for platform `iOS: 14.0+` and `tvOS: 14.0+`

## Using [Swift Package Manager](https://swift.org/package-manager/)

Swift Package Manager is a tool for managing the distribution of Swift frameworks. It integrates with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

Swift Package Manager support since `2.8.0`

We provide three products:
- `BitmovinPlayerCollector` including BitmovinPlayer v3 Collector
- `AVPlayerCollector` including AVPlayer Collector
- `AmazonIVSPlayerCollector` including Amazon IVS Player Collector

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
        .product(name: "BitmovinPlayerCollector", package: "BitmovinAnalytics"),
        .product(name: "AVPlayerCollector", package: "BitmovinAnalytics")
        .product(name: "AmazonIVSPlayerCollector", package: "BitmovinAnalytics")
      ]),
  ]
  ...
)
```
### Limitation
Executing `swift build` from the command line is currently not supported. Open the Package in Xcode if you are developing another Package depending on `BitmovinAnalytics`.

### Import BitmovinAnalyticsCollector into your Code

We have split the `BitmovinAnalytics` into 3 targets
- CoreCollector - including shared code for all collectors
- BitmovinPlayerCollector - including `BitmovinPlayer` Collector
- AVPlayerCollector - including `AVPlayer` Collector
- AmazonIVSPlayerCollector - including `AmazonIVSPlayer` Collector

if you are working with our Collectors you need to add at least `import CoreCollector` as many Classes are relocated to that package

Going further you need to import the corresponding Collector package for player

Example when using BitmovinPlayer
```
import CoreCollector
import BitmovinPlayerCollector
```

## Using [CocoaPods](https://cocoapods.org/)

We depend on `cocoapods` version `>= 1.4`. 
To install it, check which Player/version you are using and add the following lines to your Podfile:

### Bitmovin Player v3

The collector for the Bitmovin Player has a dependency on `BitmovinPlayer` version `>= 3.35.0`.

```ruby
source 'https://github.com/bitmovin/cocoapod-specs.git'
pod 'BitmovinAnalyticsCollector/Core', '2.12.0'
pod 'BitmovinAnalyticsCollector/BitmovinPlayer', '2.12.0'
pod 'BitmovinPlayer', '3.0.0'

use_frameworks!
```

### AVPlayer

```ruby
source 'https://github.com/bitmovin/cocoapod-specs.git'
pod 'BitmovinAnalyticsCollector/Core', '2.12.0'
pod 'BitmovinAnalyticsCollector/AVPlayer', '2.12.0'

use_frameworks!
```

### AmazonIVSPlayer

The collector for the Amazon IVS Player has a dependency on `AmazonIVSPlayer` version `1.18.0`.

```ruby
source 'https://github.com/bitmovin/cocoapod-specs.git'
pod 'BitmovinAnalyticsCollector/Core', '2.12.0'
pod 'BitmovinAnalyticsCollector/AmazonIVSPlayer', '2.12.0'
pod 'AmazonIVSPlayer', '1.18.0'

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
