#!/bin/sh

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
    EXPORT_TOKEN="\nexport ANALYTICS_GH_TOKEN=$ANALYTICS_GH_TOKEN"
    if test -e ~/.bashrc; then
        echo $EXPORT_TOKEN >> ~/.bashrc
    fi
    if test -e ~/.bash_profile; then
        echo $EXPORT_TOKEN >> ~/.bash_profile
    fi
fi

echo "Make sure to bump the version in the .podspec, README and CHANGELOG first and merge that PR into develop."
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
echo "Don't forget to update the changelog in Contentful."
echo "https://app.contentful.com/spaces/blfijbdi3ei3/entries"