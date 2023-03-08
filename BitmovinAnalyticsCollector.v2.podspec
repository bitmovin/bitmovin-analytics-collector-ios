
Pod::Spec.new do |s|
  s.name             = 'BitmovinAnalyticsCollector'
  s.version          = '2.10.0'
  s.summary          = 'iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics'

  s.description      = <<-DESC
iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics. This SDK can monitor an AVPlayer or a Bitmovin Player
DESC

  s.homepage         = 'https://github.com/bitmovin/bitmovin-analytics-collector-ios'
  s.author           = { 'Bitmovin Inc' => 'admin@bitmovin.com' }
  s.source           = { :git => 'https://github.com/bitmovin/bitmovin-analytics-collector-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'
  s.swift_version = '5.0'

  s.pod_target_xcconfig = {
      'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}"/*',
      'OTHER_LDFLAGS' => '$(inherited) -ObjC',
      'ENABLE_BITCODE' => 'YES'
  }
  s.subspec 'Core' do |core|
    core.source_files = 'Sources/CoreCollector/**/*.{swift}'

    core.test_spec 'CoreTests' do |core_test_spec|
      core_test_spec.source_files = 'Tests/CoreCollectorTests/**/*'
    end
  end

  s.subspec 'BitmovinPlayer' do |bitmovinplayerv3|
    bitmovinplayerv3.source_files = 'Sources/BitmovinPlayerCollector/**/*.{swift}'
    bitmovinplayerv3.tvos.dependency 'BitmovinPlayer', '~>3.0'
    bitmovinplayerv3.ios.dependency 'BitmovinPlayer', '~>3.0'

    bitmovinplayerv3.test_spec 'BitmovinPlayerTests' do |bitmovinplayerv3_test_spec|
      bitmovinplayerv3_test_spec.source_files = 'Tests/BitmovinPlayerCollectorTests/**/*'
    end
  end

  s.subspec 'AmazonIVSPlayer' do |ivsplayer|
    ivsplayer.source_files = 'Sources/AmazonIVSPlayerCollector/**/*.{swift}'
    ivsplayer.tvos.dependency 'AmazonIVSPlayer', '1.16.0'
    ivsplayer.ios.dependency 'AmazonIVSPlayer', '1.16.0'
    
    ivsplayer.test_spec 'AmazonIVSPlayerTests' do |ivsplayer_test_spec|
      ivsplayer_test_spec.source_files = 'Tests/AmazonIVSPlayerCollectorTests/**/*'
    end
  end

  s.subspec 'AVPlayer' do |avplayer|
    avplayer.source_files = 'Sources/AVPlayerCollector/**/*.{swift}'

    avplayer.test_spec 'AVPlayerTests' do |avplayer_test_spec|
      avplayer_test_spec.source_files = 'Tests/AVPlayerCollectorTests/**/*'
    end
  end

end
