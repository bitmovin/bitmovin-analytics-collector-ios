# [![bitmovin](http://bitmovin-a.akamaihd.net/webpages/bitmovin-logo-github.png)](http://www.bitmovin.com)
iOS library that allows you to monitor your iOS video playback with [Bitmovin Analytics](https://bitmovin.com/video-analytics/)

# Getting started
## Adding to your project
#### Carthage
#### Cocoapods

## Examples

The following example creates a BitmovinAnalytics object and attaches an AVPlayer instance to it. 

```swift
// Create a BitmovinAnalyticsConfig using your Bitmovin analytics license key and your Bitmovin Player Key
let config:BitmovinAnalyticsConfig = BitmovinAnalyticsConfig(key:"YOUR_ANALYTICS_KEY",playerKey:"YOUR_PLAYER_KEY")

// Create a BitmovinAnalytics object using the config just created 
analyticsCollector = BitmovinAnalytics(config: config);

// Attach your player instance
analyticsCollector.attachAVPlayer(player: player);

// Detach your player when you are done. 

```


#### Optional Configuration Parameters
```swift
config.cdnProvider = .akamai
config.customData1 = "customData1"
config.customData2 = "customData2"
config.customData3 = "customData3"
config.customData4 = "customData4"
config.customData5 = "customData5"
config.customerUserId = "customUserId"
config.experimentName = "experiement-1"
config.videoId = "iOSHLSStatic"
config.path = "/vod/breadcrumb/"
```

A [full example app]() can be seen in the github repo 
