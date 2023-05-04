
Pod::Spec.new do |s|
  s.name             = 'BitmovinAnalyticsCollector'
  s.version          = '2.11.0'
  s.summary          = 'iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics'

  s.description      = <<-DESC
iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics. This SDK can monitor an AVPlayer, a Bitmovin Player or AmazonIVSPlayer.
DESC

  s.homepage         = 'https://github.com/bitmovin/bitmovin-analytics-collector-ios'
  s.author           = { 'Bitmovin Inc' => 'support@bitmovin.com' }
  s.license = { :type => "Commercial", :file => "LICENSE.md" }

  s.ios.deployment_target = '14.0'
  s.tvos.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.source = { :http => 'https://cdn.bitmovin.com/analytics/ios_tvos/x/BitmovinAnalyticsCollector.zip' }

  s.subspec 'Core' do |core|
    core.vendored_frameworks = 'CoreCollector.xcframework'
  end

  s.subspec 'BitmovinCollector' do |bitmovinplayerv3|
    bitmovinplayerv3.vendored_frameworks = 'BitmovinCollector.xcframework'
    bitmovinplayerv3.dependency 'BitmovinPlayer', '~>3.35'
  end

  s.subspec 'AmazonIVSCollector' do |ivsplayer|
    ivsplayer.ios.deployment_target = '14.0'
    ivsplayer.ios.vendored_frameworks = 'AmazonIVSCollector.xcframework'
    ivsplayer.ios.dependency 'AmazonIVSPlayer', '1.18.0'
  end

  s.subspec 'AVFoundationCollector' do |avplayer|
    avplayer.vendored_frameworks = 'AVFoundationCollector.xcframework'
  end
end
