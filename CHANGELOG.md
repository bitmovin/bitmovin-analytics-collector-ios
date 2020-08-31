# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## Development

### Changed

- Updated `BitmovinPlayer` dependency to `2.51.0` (AN-1706) 

## 1.16.0

### Added

- Restricted number of quality changes tracked per period of time (AN-1561)
- `error` sample sent if continuous buffering exceeds threshold (ANALYTICS_BUFFERING_TIMEOUT_REACHED) (AN-1558)

## 1.15.0

### Added

- Tracking of drm metrics (`drmType`, `drmLoadTime`) for Bitmovin player if Fairplay DRM system is used (AN-195, AN-1515)
- Tracking of `drmType` for AVFoundation player if Fairplay DRM system is used (AN-1515)

### Changed

- Tracking of video startup times when having autoplay enabled to be consistent with web platform (AN-1617)

## 1.14.0

### Added

- AVPlayer: `errorData` to sample (AN-1453)

### Changed

- Bitmovin Player: send `qualitychange` samples only when bitrate changed (AN-1512)

## 1.13.0

### Added

- heartbeat during Rebuffer state (AN-1283)

### Fixed

- Bitmovin Player: use correct error message from `ErrorEvent` (AN-1325)
- Bitmovin Player: seeking transitioned into play although seeking still present (AN-1411, AN-1400)

## 1.12.0

### Added

- Bitmovin Player: Track playback start failure and reason (AN-1084)

## v1.11.0

### Added

- Added Analytics AdAdapter for Bitmovin Player
- New boolean configuration field called `ads` to indicate that Ads should be tracked.

## v1.10.1

### Fixed

- `videoTimeEnd` is set to `videoDuration` in the `playbackFinished` event
- Resolution of `videoTimeStart` and `videoTimeEnd` is now in milliseconds instead of seconds
- Collector triggered outgoing payload in pause state

## v1.10.0

### Added

- added `customData6` and `customData7` to outgoing payload

## v1.9.0

### Added

- iOS and tvOS binaries
- Scripts to build iOS and tvOS binaries
- New boolean configuration field called `isLive` to indicate if the upcoming stream is a live stream. Will be overridden once playback metadata is available.

## v1.8.0

### Added

- `subtitleEnabled` and `subtitleLanguage` in outgoing payload 
- `audioLanguage` in outgoing payload

## 1.7.5

### Added

- `@objc` annotations to allow embedding the Collector in Objective-C Applications

## 1.7.4

### Fixed

- Xcode 10.2 and Swift 5.0 updates

## 1.7.3

### Fixed

- Fixed occasional crashes when `currentPlayTime` from player is NaN

## 1.7.2

### Fixed

- AVPlayer reported some warnings as errors and got stuck in an error state, even if playback was able to continue

## 1.7.1

### Added

### Changed

- AVPlayer Collector now reports `playerVersion` as `avplayer-<iOS-Version>`
- Bitmovin Collector now reports `playerVersion` as `bitmovin-<SDK-version>`

### Fixed

- Collector didn't populate `buffered` field when buffering occured
- Collector didn't correctly report `streamFormat`, `m3u8Url`, `mpdUrl` or `progUrl`
- `videoTimeStart` and `videoTimeEnd` were not set when sending out heartbeats
- Collector didn't report errors when using the `AVPlayerCollector` 
- Collector didn't reset on `onSourceUnloaded` and continued sending samples with the inital `impression_id`, if `detachPlayer` wasn't called 

## 1.7.0

### Added

- `audioCodec` and `videoCodec` in outgoing payload
- `supportedVideoCodecs` in outgoing payload

### Fixed

- Collector didn't report the correct version of the Bitmovin player
- Added additional cases to the  `platform` field (`watchOS`,  `macOS`, `Linux` and `unknown`) 

## 1.6.0
- Split project into Core, AVPlayer and BitmovinPlayer to avoid unnecessary dependency imports
- Added debug logging for denied licensing requests to facilitate debugging of whitelisted package names

## 1.5.3

### Added

- Payload now sends out `platform` field
- Payload now contains a `sequenceNumber`
