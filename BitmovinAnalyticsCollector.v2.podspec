
Pod::Spec.new do |s|
  s.name             = 'BitmovinAnalyticsCollector'
  s.version          = '2.11.1'
  s.summary          = 'iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics'

  s.description      = <<-DESC
iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics. This SDK can monitor an AVPlayer or a Bitmovin Player
DESC

  s.homepage         = 'https://github.com/bitmovin/bitmovin-analytics-collector-ios'
  s.author           = { 'Bitmovin Inc' => 'admin@bitmovin.com' }
  s.source           = { :git => 'https://github.com/bitmovin/bitmovin-analytics-collector-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.tvos.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.pod_target_xcconfig = {
      'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}"/*',
      'OTHER_LDFLAGS' => '$(inherited) -ObjC',
      'ENABLE_BITCODE' => 'YES'
  }
  s.subspec 'Core' do |core|
    core.source_files = 'Sources/CoreCollector/**/*.{swift}'
  end

  s.subspec 'BitmovinPlayer' do |bitmovinplayerv3|
    bitmovinplayerv3.source_files = 'Sources/BitmovinPlayerCollector/**/*.{swift}'
    bitmovinplayerv3.tvos.dependency 'BitmovinPlayer', '~>3.35'
    bitmovinplayerv3.ios.dependency 'BitmovinPlayer', '~>3.35'
  end

  s.subspec 'AmazonIVSPlayer' do |ivsplayer|
    ivsplayer.source_files = 'Sources/AmazonIVSPlayerCollector/**/*.{swift}'
    ivsplayer.tvos.dependency 'AmazonIVSPlayer', '1.18.0'
    ivsplayer.ios.dependency 'AmazonIVSPlayer', '1.18.0'
  end

  s.subspec 'AVPlayer' do |avplayer|
    avplayer.source_files = 'Sources/AVPlayerCollector/**/*.{swift}'
  end

end
