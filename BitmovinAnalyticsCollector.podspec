
Pod::Spec.new do |s|
  s.name             = 'BitmovinAnalyticsCollector'
  s.version          = '1.30.0'
  s.summary          = 'iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics'

  s.description      = <<-DESC
iOS library that allows you to monitor your iOS video playback with Bitmovin Analytics. This SDK can monitor an AVPlayer or a Bitmovin Player
DESC

  s.homepage         = 'https://github.com/bitmovin/bitmovin-analytics-collector-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bitmovin Inc' => 'admin@bitmovin.com' }
  s.source           = { :git => 'https://github.com/bitmovin/bitmovin-analytics-collector-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.swift_version = '5.0'

  s.pod_target_xcconfig = {
      'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}"/*',
      'OTHER_LDFLAGS' => '$(inherited) -ObjC',
      'ENABLE_BITCODE' => 'YES'
  }
  s.subspec 'Core' do |core|
    core.source_files = 'BitmovinAnalyticsCollector/Classes/Collector/**/*.{swift}'

    core.test_spec 'CoreTests' do |core_test_spec|
      core_test_spec.source_files = 'BitmovinAnalyticsCollector/Tests/CoreTests/**/*'
    end
  end

  s.subspec 'BitmovinPlayer' do |bitmovinplayer|
    bitmovinplayer.source_files = 'BitmovinAnalyticsCollector/Classes/BitmovinPlayer/**/*.{swift}'
    bitmovinplayer.tvos.dependency 'BitmovinPlayer', '~>2.51'
    bitmovinplayer.ios.dependency 'BitmovinPlayer', '~>2.51'

    bitmovinplayer.test_spec 'BitmovinPlayerTests' do |bitmovinplayer_test_spec|
      bitmovinplayer_test_spec.source_files = 'BitmovinAnalyticsCollector/Tests/BitmovinPlayerTests/**/*'
    end
  end

  s.subspec 'AVPlayer' do |avplayer|
    avplayer.source_files = 'BitmovinAnalyticsCollector/Classes/AVPlayer/**/*.{swift}'

    avplayer.test_spec 'AVPlayerTests' do |avplayer_test_spec|
      avplayer_test_spec.source_files = 'BitmovinAnalyticsCollector/Tests/AVPlayerTests/**/*'
    end
  end

end
