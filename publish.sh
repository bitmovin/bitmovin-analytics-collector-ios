#!/bin/sh

setEnvVariable () {
  EXPORT_TOKEN="\nexport $1=$2"
    if test -e ~/.bashrc; then
        echo $EXPORT_TOKEN >> ~/.bashrc
    fi
    if test -e ~/.bash_profile; then
        echo $EXPORT_TOKEN >> ~/.bash_profile
    fi
}

notifyApi () {
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
}

if test -e ~/.bashrc; then
  source ~/.bashrc
fi
if test -e ~/.bash_profile; then
  source ~/.bash_profile
fi

if [ -z "$ANALYTICS_GH_TOKEN" ]; then
    echo "ANALYTICS_GH_TOKEN not found in environment variables. You need to provide the Github Access Token for the user bitAnalyticsCircleCi. This can be found in LastPass."
    echo "Enter the token:"
    read ANALYTICS_GH_TOKEN
    setEnvVariable "ANALYTICS_GH_TOKEN" $ANALYTICS_GH_TOKEN
fi

if [ -z "$ANALYTICS_API_RELEASE_TOKEN" ]; then
    echo "ANALYTICS_API_RELEASE_TOKEN not found in environment variables. You need to provide the API Key for the user dhi+analytics-admin-user for https://api.bitmovin.com."
    echo "Enter the token:"
    read ANALYTICS_API_RELEASE_TOKEN
    setEnvVariable "ANALYTICS_API_RELEASE_TOKEN" $ANALYTICS_API_RELEASE_TOKEN
fi

echo "Make sure you have fastlane installed on your computer before releasing: (sudo gem install fastlane -NV)"
echo "Make sure to bump the version in the .podspec (use the latest v1 version), Specs\Development-V2\*.podspec (use the latest v2 version), README and CHANGELOG first and merge that PR into develop."
echo "If you've changed the version of the player dependency, make sure to also update the .podspec.json files in the Specs folder."
echo "Version (without leading \"v\")":
read VERSION
git checkout develop
git pull
git checkout main
git pull
git merge develop
git tag -a $VERSION -m "v$VERSION"
git push origin main $VERSION

echo "Pushed \"main\" and \"$VERSION\" to internal repo."
git push git@github.com:bitmovin/bitmovin-analytics-collector-ios.git main $VERSION
echo "Pushed \"main\" and \"$VERSION\" to public repo."

curl \
  -u bitAnalyticsCircleCi:$ANALYTICS_GH_TOKEN \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/bitmovin/bitmovin-analytics-collector-ios/releases \
  -d "{\"tag_name\":\"$VERSION\", \"name\": \"v$VERSION\", \"draft\": false}"

echo "Created release in public repo."

bundle exec fastlane release

echo "Don't forget to create and merge the pull request in the cocoapod-specs repo."

notifyApi "ios" $VERSION
notifyApi "tvos" $VERSION

echo "Don't forget to update the changelog in Contentful."
open "https://app.contentful.com/spaces/blfijbdi3ei3/entries"