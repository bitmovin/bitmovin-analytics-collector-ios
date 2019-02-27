
Pod::Spec.new do |s|
  s.name             = 'BitmovinAnalyticsCollector'
  s.version          = '1.5.0'
  s.summary          = 'iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics'

  s.description      = <<-DESC
iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics. This SDK can monitor an AVPlayer or a Bitmovin Player
DESC

  s.homepage         = 'https://github.com/bitmovin/bitmovin-analytics-collector-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cory Zachman' => 'cory.zachman@bitmovin.com' }
  s.source           = { :git => 'https://github.com/bitmovin/bitmovin-analytics-collector-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.swift_version = '4.0'

  s.subspec 'Core' do |core|
    core.source_files = 'BitmovinAnalyticsCollector/Classes/Collector/**/*.{swift}' 
  end

  s.subspec 'BitmovinPlayer' do |bitmovinplayer|
    bitmovinplayer.source_files = 'BitmovinAnalyticsCollector/Classes/BitmovinPlayer/**/*.{swift}'    
    bitmovinplayer.tvos.dependency 'BitmovinPlayer', '~>2.11'
    bitmovinplayer.ios.dependency 'BitmovinPlayer', '~>2.11'
  end

  s.subspec 'AVPlayer' do |avplayer|
    avplayer.source_files = 'BitmovinAnalyticsCollector/Classes/AVPlayer/**/*.{swift}'
  end

end
