
preparePods() {
  echo "-----------------"
  echo "Preparing Pods---"
  echo "-----------------"
  cd Examples
  pod install --repo-update --silent
  cd ../Examples-BitmovinPlayerV3
  pod install --repo-update --silent
  cd ..
}

buildAll() {
  echo "Start building xcode projects based on cocoapods for iOS"
  xcodebuild -quiet -workspace Examples/BitmovinAnalyticsCollector.xcworkspace -scheme BitmovinAnalyticsCollector-Example-iOS -sdk iphoneos -destination 'name=iPhone 13' clean build || CHECKS_PASSED=0
  xcodebuild -quiet -workspace Examples-BitmovinPlayerV3/BitmovinAnalyticsCollector-BitmovinPlayerV3.xcworkspace -scheme BitmovinAnalyticsCollector-Example-BitmovinPlayerV3-iOS -sdk iphoneos -destination 'name=iPhone 13' clean build || CHECKS_PASSED=0

  # echo "Start building xcode projects based on cocoapods for tvOS"
  # xcodebuild -quiet -workspace Examples/BitmovinAnalyticsCollector.xcworkspace -scheme BitmovinAnalyticsCollector-Example-tvOS -sdk appletvos analyze || CHECKS_PASSED=0
  # xcodebuild -quiet -workspace Examples-BitmovinPlayerV3/BitmovinAnalyticsCollector-BitmovinPlayerV3.xcworkspace -scheme BitmovinAnalyticsCollector-Example-BitmovinPlayerV3-tvOS -sdk appletvos analyze || CHECKS_PASSED=0

  echo "Start building xcode projects based on swiftpm"
  xcodebuild -quiet -workspace .swiftpm/xcode/package.xcworkspace -scheme BitmovinPlayerCollector -sdk iphoneos -destination 'name=iPhone 13' clean build || CHECKS_PASSED=0
  xcodebuild -quiet -workspace .swiftpm/xcode/package.xcworkspace -scheme AVPlayerCollector -sdk iphoneos -destination 'name=iPhone 13' clean build || CHECKS_PASSED=0
}

testAll() {
  echo "Successfully build all projects - Starting with tests"
  TESTS_PASSED=1
  xcodebuild -quiet -workspace Examples/BitmovinAnalyticsCollector.xcworkspace -scheme BitmovinAnalyticsCollector-Example-iOS -sdk iphoneos -destination 'name=iPhone 13' clean test || TESTS_PASSED=0
  xcodebuild -quiet -workspace Examples-BitmovinPlayerV3/BitmovinAnalyticsCollector-BitmovinPlayerV3.xcworkspace -scheme BitmovinAnalyticsCollector-Example-BitmovinPlayerV3-iOS -sdk iphoneos -destination 'name=iPhone 13' clean test || TESTS_PASSED=0
  if [ $TESTS_PASSED -eq 0 ]
  then
    CHECKS_PASSED=0
    echo "--------------------------"
    echo "-------Tests FAILED-------"
  fi
}

checkForSwiftPMProject() {
  swiftpmDIR='.swiftpm'
  if ! [ -d $swiftpmDIR ]
  then
    echo "SwiftPm project has never been opened. Will open project to create project files"
    open Package.swift || echo "-------------------------------Problem openign swiftpm project ---------------------------------"
  fi
}

# Prepare for builds
preparePods
checkForSwiftPMProject

# Build
CHECKS_PASSED=1 
buildAll

# If successfully built -> Test
if [ $CHECKS_PASSED -eq 1 ]
then 
  testAll
fi

if [ $CHECKS_PASSED -eq 0 ]
then
  echo "--------------------------------------------"
  echo "Build of Collector project ---- FAILED -----"
  echo "--------------------------------------------"
  exit 1
fi

echo "-----------------------------------------------"
echo "Build of Collector project ---- SUCCEEDED -----"
echo "-----------------------------------------------"
exit 0