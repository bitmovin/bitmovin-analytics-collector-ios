PLATFORM=$1
VERSION=$2
curl "https://api.bitmovin.com/v1/admin/analytics/releases/$PLATFORM/v$VERSION" -H "X-Api-Key:$ANALYTICS_API_RELEASE_TOKEN" -H "Content-Type:application/json" \
  --data-binary "{
      \"podName\": \"BitmovinAnalyticsCollector\",
      \"gitUrl\":\"https://github.com/bitmovin/bitmovin-analytics-collector-ios.git\",
      \"gitTag\": \"$VERSION\"
    }" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "Published Release $PLATFORM:$VERSION to Bitmovin API"
else
  echo "Failed to publish release to Bitmovin API"
fi