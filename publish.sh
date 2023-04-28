#!/bin/sh

# Exit on any error
set -e 

# do not continue if you fail in a pipe ( | )
set -o pipefail

echo "Run the GitHub Action with the desired version"
open "https://github.com/bitmovin-engineering/bitmovin-analytics-collector-ios-internal/actions/workflows/release.yml"

echo "Don't forget to update the changelog once done."
open "https://dash.readme.com/project/bitmovin-playback/v1/docs/analytics-collector-ios-releases"
