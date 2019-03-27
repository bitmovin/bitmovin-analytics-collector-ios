# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## Development

## 1.6.0
- Split project into Core, AVPlayer and BitmovinPlayer to avoid unnecessary dependency imports
- Added debug logging for denied licensing requests to facilitate debugging of whitelisted package names

## 1.5.3

### Added

- Payload now sends out `platform` field
- Payload now contains a `sequenceNumber`
