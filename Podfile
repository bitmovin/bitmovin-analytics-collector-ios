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

def google_Adsima_sdk
  pod 'GoogleAds-IMA-iOS-SDK', '3.18.4'
end

def google_cast_sdk
  pod 'google-cast-sdk', '4.6.1'
end

def amazon_ivs_player
  pod 'AmazonIVSPlayer', '1.18.0'
end

target 'CollectorDemoApp' do
  use_frameworks!
  collector_demo_app_project
  for_ios
  amazon_ivs_player
  google_Adsima_sdk
  google_cast_sdk
end

target 'CollectorDemoAppTV' do
  use_frameworks!
  collector_demo_app_project
  for_tvos
end
