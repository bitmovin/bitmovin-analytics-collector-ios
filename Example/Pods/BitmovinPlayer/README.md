# bitmovin-player-ios-sdk-cocoapod
This repository contains all released versions of the Bitmovin Player iOS SDK.

## Sample Applications
Find some sample applications using the Bitmovin Player iOS SDK in our [sample repository](https://github.com/bitmovin/bitmovin-player-ios-samples).

## Using the SDK
### Using CocoaPods
Add `pod 'BitmovinPlayer', git: 'https://github.com/bitmovin/bitmovin-player-ios-sdk-cocoapod.git', tag: '2.7.0` to your Podfile. After that, install the pod using `pod install`. 

### Adding The SDK Directly
+   When using XCode, go to the `General` settings page and add the SDK bundle (`BitmovinPlayer.framework`) under `Linked Frameworks and Libraries`.

### Project Setup
+   Add your Bitmovin player license key to the `Info.plist` file as `BitmovinPlayerLicenseKey`.

    Your player license key can be found when logging in into [https://dashboard.bitmovin.com](https://dashboard.bitmovin.com)  and navigating to `Player -> Licenses`.

+   Add the Bundle identifier of the iOS application which is using the SDK as an allowed domain to the Bitmovin licensing backend. This can also be done under `Player -> Licenses` when logging in into [https://dashboard.bitmovin.com](https://dashboard.bitmovin.com) with your account.

    When you do not do this, you'll get a license error when starting the application which contains the player.

## Documentation And Release Notes
-   You can find the latest API documentation [here](https://bitmovin.com/ios-sdk-documentation/)
-   The release notes can be found [here](https://bitmovin.com/release-notes-ios-sdk/)
