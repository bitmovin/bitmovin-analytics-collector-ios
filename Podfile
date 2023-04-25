source 'https://github.com/bitmovin/cocoapod-specs.git'
source 'https://cdn.cocoapods.org/'

workspace 'BitmovinAnalyticsCollector'

def collector_demo_app_project
    project 'CollectorDemoApp/CollectorDemoApp.xcodeproj'
end

def for_ios
  platform :ios, '14.0'
end

def for_tvos
  platform :tvos, '14.0'
end

def collectors
  pod 'BitmovinAnalyticsCollector/Core', :path => './BitmovinAnalyticsCollector.v2.podspec'
  pod 'BitmovinAnalyticsCollector/AVPlayer', :path => './BitmovinAnalyticsCollector.v2.podspec'
  pod 'BitmovinAnalyticsCollector/BitmovinPlayer', :path => './BitmovinAnalyticsCollector.v2.podspec'
  pod 'BitmovinAnalyticsCollector/AmazonIVSPlayer', :path => './BitmovinAnalyticsCollector.v2.podspec'
end

def tv_collectors
  pod 'BitmovinAnalyticsCollector/Core', :path => './BitmovinAnalyticsCollector.v2.podspec'
  pod 'BitmovinAnalyticsCollector/AVPlayer', :path => './BitmovinAnalyticsCollector.v2.podspec'
  pod 'BitmovinAnalyticsCollector/BitmovinPlayer', :path => './BitmovinAnalyticsCollector.v2.podspec'
end

def google_Adsima_sdk
  pod 'GoogleAds-IMA-iOS-SDK', '3.18.4'
end

def google_cast_sdk
  pod 'google-cast-sdk', '4.6.1'
end


target 'CollectorDemoApp' do
  use_frameworks!
  collector_demo_app_project
  for_ios
  google_Adsima_sdk
  google_cast_sdk
end

target 'CollectorDemoAppTV' do
  use_frameworks!
  collector_demo_app_project
  for_tvos
end
