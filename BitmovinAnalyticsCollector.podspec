#
# Be sure to run `pod lib lint BitmovinAnalyticsCollector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BitmovinAnalyticsCollector'
  s.version          = '1.0.0'
  s.summary          = 'iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics'

  s.description      = <<-DESC
iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics. This SDK can monitor an AVPlayer or a Bitmovin Player
DESC

  s.homepage         = 'https://github.com/bitmovin/bitmovin-analytics-collector-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cory Zachman' => 'cory.zachman@bitmovin.com' }
  s.source           = { :git => 'https://github.com/bitmovin/bitmovin-analytics-collector-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'BitmovinAnalyticsCollector/Classes/**/*'
  s.dependency 'BitmovinPlayer', '~>2.7.0'

end
