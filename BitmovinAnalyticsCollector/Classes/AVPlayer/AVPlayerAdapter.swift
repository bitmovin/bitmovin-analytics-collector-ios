import AVFoundation
import Foundation

class AVPlayerAdapter: CorePlayerAdapter, PlayerAdapter {
    static let periodicTimeObserverIntervalSeconds = 0.2
    static let minSeekDeltaSeconds = periodicTimeObserverIntervalSeconds + 0.3
    
    private static var playerKVOContext = 0
    private let config: BitmovinAnalyticsConfig
    @objc private var player: AVPlayer
    var statusObserver: NSKeyValueObservation?
    
    // We need to have our own instances to be able to operate in time
    private let notificationCenter: NotificationCenter
    private let queue = DispatchQueue.init(label: "com.bitmovin.analytics.avplayeradapter")
    
    private var isMonitoring = false
    private var currentVideoBitrate: Double = 0
    private var isPlayerReady = false
    internal var currentSourceMetadata: SourceMetadata?
    
    // used for seek tracking
    private var previousTime: CMTime?
    private var previousTimestamp: Int64 = 0
    
    internal var drmDownloadTime: Int64?
    private var drmType: String?
    
    private var timeObserver: Any?
    private let errorHandler: ErrorHandler
    
    init(player: AVPlayer,
         config: BitmovinAnalyticsConfig,
         stateMachine: StateMachine,
         notificationCenter: NotificationCenter = NotificationCenter.default
    ) {
        self.player = player
        self.config = config
        self.errorHandler = ErrorHandler()
        self.notificationCenter = notificationCenter
        super.init(stateMachine: stateMachine)
    }
    
    func initialize() {
        resetSourceState()
        startMonitoring()
    }
    
    deinit {
        self.destroy()
    }
    
    func resetSourceState() {
        currentVideoBitrate = 0
        previousTime = nil
        previousTimestamp = 0
        drmType = nil
        drmDownloadTime = nil
    }
    
    public func startMonitoring() {
        if isMonitoring  {
            stopMonitoring()
        }
        isMonitoring = true
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(AVPlayerAdapter.periodicTimeObserverIntervalSeconds, preferredTimescale: Int32(NSEC_PER_SEC)), queue: self.queue) { [weak self] time in
            self?.onTimeChanged(playerTime: time)
        }
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.new, .initial, .old], context: &AVPlayerAdapter.playerKVOContext)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.new, .initial, .old], context: &AVPlayerAdapter.playerKVOContext)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial, .old], context: &AVPlayerAdapter.playerKVOContext)
    }

    override public func stopMonitoring() {
        guard isMonitoring else {
            return
        }
        isMonitoring = false
        
        if let playerItem = player.currentItem {
            stopMonitoringPlayerItem(playerItem: playerItem)
        }
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate), context: &AVPlayerAdapter.playerKVOContext)
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), context: &AVPlayerAdapter.playerKVOContext)
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status), context: &AVPlayerAdapter.playerKVOContext)
        
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        resetSourceState()
    }

    private func updateDrmPerformanceInfo(_ playerItem: AVPlayerItem) {
        let asset = playerItem.asset
        asset.loadValuesAsynchronously(forKeys: ["hasProtectedContent"]) { [weak self] in
            guard let adapter = self else {
                return
            }
            var error: NSError?
            if asset.statusOfValue(forKey: "hasProtectedContent", error: &error) == .loaded {
                // Access the property value synchronously.
                if asset.hasProtectedContent {
                    adapter.drmType = DrmType.fairplay.rawValue
                } else {
                    adapter.drmType = nil
                }
            }
        }
    }

    private func startMonitoringPlayerItem(playerItem: AVPlayerItem) {
        statusObserver = playerItem.observe(\.status) {[weak self] (item, _) in
            self?.playerItemStatusObserver(playerItem: item)
        }
        self.notificationCenter.addObserver(self, selector: #selector(observeNewAccessLogEntry(notification:)), name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: playerItem)
        self.notificationCenter.addObserver(self, selector: #selector(timeJumped(notification:)), name: AVPlayerItem.timeJumpedNotification, object: playerItem)
        self.notificationCenter.addObserver(self, selector: #selector(playbackStalled(notification:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        self.notificationCenter.addObserver(self, selector: #selector(failedToPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        self.notificationCenter.addObserver(self, selector: #selector(didPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        updateDrmPerformanceInfo(playerItem)
    }

    private func stopMonitoringPlayerItem(playerItem: AVPlayerItem) {
        self.notificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: playerItem)
        self.notificationCenter.removeObserver(self, name: AVPlayerItem.timeJumpedNotification, object: playerItem)
        self.notificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        self.notificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        self.notificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        statusObserver?.invalidate()
    }

    private func playerItemStatusObserver(playerItem: AVPlayerItem) {
        switch playerItem.status {
            case .readyToPlay:
                isPlayerReady = true
            
            case .failed:
                errorOccured(error: playerItem.error as NSError?)

            default:
                break
        }
    }

    private func errorOccured(error: NSError?) {
        let errorCode = error?.code ?? 1
        guard errorHandler.shouldSendError(errorCode: errorCode) else {
            return
        }
        
        let errorData = ErrorData(code: errorCode, message: error?.localizedDescription ?? "Unknown", data: error?.localizedFailureReason)
        
        if (!stateMachine.didStartPlayingVideo && stateMachine.didAttemptPlayingVideo) {
            stateMachine.onPlayAttemptFailed(withReason:VideoStartFailedReason.playerError, withError: errorData)
        } else {
            stateMachine.error(withError: errorData, time: player.currentTime())
        }
    }

    @objc private func failedToPlayToEndTime(notification: Notification) {
        let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError
        errorOccured(error: error)
    }

    @objc private func didPlayToEndTime(notification: Notification) {
        stateMachine.pause(time: player.currentTime())
    }

    @objc private func playbackStalled(notification _: Notification) {
        stateMachine.transitionState(destinationState: .buffering, time: player.currentTime())
    }

    @objc private func observeNewAccessLogEntry(notification: Notification) {
        guard let item = notification.object as? AVPlayerItem, let event = item.accessLog()?.events.last else {
            return
        }
        
        let newBitrate = event.indicatedBitrate
        
        if currentVideoBitrate == 0 {
            currentVideoBitrate = newBitrate
            return
        }
        
        // bitrate needs to change in order to trigger state change
        if currentVideoBitrate == newBitrate {
            return
        }
        
        stateMachine.videoQualityChange(time: player.currentTime()) { [weak self] in
            self?.currentVideoBitrate = newBitrate
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &AVPlayerAdapter.playerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if keyPath == #keyPath(AVPlayer.rate) {
            onRateChanged(change)
        } else if keyPath == #keyPath(AVPlayer.currentItem) {
            if let oldItem = change?[NSKeyValueChangeKey.oldKey] as? AVPlayerItem {
                NSLog("Current Item Changed: %@", oldItem.debugDescription)
                stopMonitoringPlayerItem(playerItem: oldItem)
            }
            if let currentItem = change?[NSKeyValueChangeKey.newKey] as? AVPlayerItem {
                NSLog("Current Item Changed: %@", currentItem.debugDescription)
                startMonitoringPlayerItem(playerItem: currentItem)
                if player.rate > 0 {
                    startup()
                }
            }
        } else if keyPath == #keyPath(AVPlayer.status) && player.status == .failed {
            errorOccured(error: self.player.currentItem?.error as NSError?)
        }
    }
    
    private func onRateChanged(_ change: [NSKeyValueChangeKey: Any]?) {
        let oldRate = change?[NSKeyValueChangeKey.oldKey] as? NSNumber ?? 0;
        let newRate = change?[NSKeyValueChangeKey.newKey] as? NSNumber ?? 0;

        if(newRate.floatValue == 0 && oldRate.floatValue != 0) {
            stateMachine.pause(time: player.currentTime())
        } else if (newRate.floatValue != 0 && oldRate.floatValue == 0 && self.player.currentItem != nil) {
            startup()
        }
    }
    
    // if seek into unbuffered area (no data) we get this event and know that it's a seek
    @objc private func timeJumped(notification _: Notification) {
        stateMachine.transitionState(destinationState: .seeking, time: previousTime)
    }
    
    private func onTimeChanged(playerTime: CMTime){
        checkSeek(playerTime)
        checkPlaying(playerTime)
        previousTime = playerTime
        previousTimestamp = Date().timeIntervalSince1970Millis
    }
    
    // if seek into buffered area no timeJumped event occur and we register seek event here
    private func checkSeek(_ playerTime: CMTime) {
        // if no previous time is tracked - ignore
        guard let prevPlayerTime = previousTime else {
            return
        }
        
        // if time dif between previous tracked playerTime and
        // the current playerTime is bigger than the minimal seek time, it's a seek
        let timeDelta = abs(CMTimeGetSeconds(playerTime - prevPlayerTime))
        if timeDelta < AVPlayerAdapter.minSeekDeltaSeconds {
            return
        }
        
        // here we know that a seek was triggered one time changed event before
        // that's why we use the prevPlayerTime and we also override the enterTimestamp
        stateMachine.seek(time: prevPlayerTime, overrideEnterTimestamp: previousTimestamp)
    }
    
    private func checkPlaying(_ currentTime: CMTime) {
        // time must have changed
        if currentTime == previousTime {
            return
        }
        
        // buffer is full enough to actually continue the playback
        if player.currentItem?.isPlaybackLikelyToKeepUp == false {
            return;
        }
        
        if player.rate == 0 {
            return
        }
        
        stateMachine.playing(time: currentTime)
    }
    
    private func startup() {
        stateMachine.play(time: player.currentTime())
    }

    func decorateEventData(eventData: EventData) {
        // Player
        eventData.player = PlayerType.avplayer.rawValue

        // Player Tech
        eventData.playerTech = "ios:avplayer"

        // Duration
        if let duration = player.currentItem?.duration, CMTIME_IS_NUMERIC(_: duration) {
            eventData.videoDuration = Int64(CMTimeGetSeconds(duration) * BitmovinAnalyticsInternal.msInSec)
        }

        // isCasting
        eventData.isCasting = player.isExternalPlaybackActive

        // DRM Type
        eventData.drmType = self.drmType
        

        // isLive
        let duration = player.currentItem?.duration
        if duration != nil && self.isPlayerReady {
            eventData.isLive = CMTIME_IS_INDEFINITE(duration!)
        } else {
            eventData.isLive = config.isLive
        }

        // version
        eventData.version = PlayerType.avplayer.rawValue + "-" + UIDevice.current.systemVersion

        if let urlAsset = (player.currentItem?.asset as? AVURLAsset),
           let streamFormat = Util.streamType(from: urlAsset.url.absoluteString) {
            eventData.streamFormat = streamFormat.rawValue
            switch streamFormat {
            case .dash:
                eventData.mpdUrl = urlAsset.url.absoluteString
                //not possible to get audio bitrate from AVPlayer for adaptive streaming
            case .hls:
                eventData.m3u8Url = urlAsset.url.absoluteString
                //not possible to get audio bitrate from AVPlayer for adaptive streaming
            case .progressive:
                eventData.progUrl = urlAsset.url.absoluteString
                //audio bitrate for progressive streaming
                eventData.audioBitrate = getAudioBitrateFromProgressivePlayerItem(forItem: player.currentItem) ?? 0.0
            case .unknown:
                break
            }
        }

        // video bitrate
        eventData.videoBitrate = currentVideoBitrate

        // videoPlaybackWidth
        if let width = player.currentItem?.presentationSize.width {
            eventData.videoPlaybackWidth = Int(width)
        }

        // videoPlaybackHeight
        if let height = player.currentItem?.presentationSize.height {
            eventData.videoPlaybackHeight = Int(height)
        }

        let scale = UIScreen.main.scale
        // screenHeight
        eventData.screenHeight = Int(UIScreen.main.bounds.size.height * scale)

        // screenWidth
        eventData.screenWidth = Int(UIScreen.main.bounds.size.width * scale)

        // isMuted
        if player.volume == 0 {
            eventData.isMuted = true
        }
    }
    
    func getAudioBitrateFromProgressivePlayerItem(forItem playerItem: AVPlayerItem?) -> Float64? {
        // audio bitrate for progressive sources
        guard let asset = playerItem?.asset else {
            return nil
        }
        if asset.tracks.isEmpty {
            return nil
        }
        
        let tracks = asset.tracks(withMediaType: .audio)
        if tracks.isEmpty {
            return nil
        }
        
        let desc = tracks[0].formatDescriptions[0] as! CMAudioFormatDescription
        let basic = CMAudioFormatDescriptionGetStreamBasicDescription(desc)
        
        guard let sampleRate = basic?.pointee.mSampleRate else {
            return nil
        }
        
        return sampleRate
    }

    var currentTime: CMTime? {
        get {
            return player.currentTime()
        }
    }
}
