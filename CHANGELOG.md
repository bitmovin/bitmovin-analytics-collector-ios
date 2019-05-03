# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## Development

### Added

### Changed

- AVPlayer Collector now reports `playerVersion` as `avplayer-<iOS-Version>`
- Bitmovin Collector now reports `playerVersion` as `bitmovin-<SDK-version>`

### Fixed

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
