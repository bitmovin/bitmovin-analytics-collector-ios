import AVFoundation
import Foundation

class AVPlayerAdapter: CorePlayerAdapter, PlayerAdapter {
    static let timeJumpedDuplicateTolerance = 1_000
    static let maxSeekOperation = 10_000
    
    private static var playerKVOContext = 0
    private let config: BitmovinAnalyticsConfig
    @objc private var player: AVPlayer
    let lockQueue = DispatchQueue.init(label: "com.bitmovin.analytics.avplayeradapter")
    var statusObserver: NSKeyValueObservation?
    
    private var isMonitoring = false
    private var isPlaying = false
    private var currentVideoBitrate: Double = 0
    private var previousTime: CMTime?
    private var isPlayerReady = false
    
    internal var drmDownloadTime: Int64?
    private var drmType: String?
    
    private var timeObserver: Any?
    private let errorHandler: ErrorHandler
    
    init(player: AVPlayer, config: BitmovinAnalyticsConfig, stateMachine: StateMachine) {
        self.player = player
        self.config = config
        self.errorHandler = ErrorHandler()
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
        drmType = nil
        drmDownloadTime = nil
    }
    
    public func startMonitoring() {
        if isMonitoring  {
            stopMonitoring()
        }
        isMonitoring = true
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.2, preferredTimescale: Int32(NSEC_PER_SEC)), queue: .main) { [weak self] time in
            self?.onPlayerDidChangeTime(currentTime: time)
        }
        
        addObserver(self, forKeyPath: #keyPath(player.rate), options: [.new, .initial, .old], context: &AVPlayerAdapter.playerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem), options: [.new, .initial, .old], context: &AVPlayerAdapter.playerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.status), options: [.new, .initial, .old], context: &AVPlayerAdapter.playerKVOContext)
    }

    override public func stopMonitoring() {
        guard isMonitoring else {
            return
        }
        isMonitoring = false
        isPlaying = false
        
        if let playerItem = player.currentItem {
            stopMonitoringPlayerItem(playerItem: playerItem)
        }
        removeObserver(self, forKeyPath: #keyPath(player.rate), context: &AVPlayerAdapter.playerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem), context: &AVPlayerAdapter.playerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.status), context: &AVPlayerAdapter.playerKVOContext)
        
        if(timeObserver != nil) {
            player.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
        
        resetSourceState()
    }

    private func updateDrmPerformanceInfo(_ playerItem: AVPlayerItem) {
        if playerItem.asset.hasProtectedContent {
            drmType = DrmType.fairplay.rawValue
        } else {
            drmType = nil
        }
    }

    private func startMonitoringPlayerItem(playerItem: AVPlayerItem) {
        statusObserver = playerItem.observe(\.status) {[weak self] (item, _) in
            self?.playerItemStatusObserver(playerItem: item)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(accessItemAdded(notification:)), name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(timeJumped(notification:)), name: NSNotification.Name.AVPlayerItemTimeJumped, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled(notification:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        updateDrmPerformanceInfo(playerItem)
    }

    private func stopMonitoringPlayerItem(playerItem: AVPlayerItem) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemTimeJumped, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        statusObserver?.invalidate()
    }

    private func playerItemStatusObserver(playerItem: AVPlayerItem) {
        let timestamp = Date().timeIntervalSince1970Millis
        
        switch playerItem.status {
            case .readyToPlay:
                isPlayerReady = true
                lockQueue.sync {
                    if stateMachine.didStartPlayingVideo && stateMachine.potentialSeekStart > 0 && (timestamp - stateMachine.potentialSeekStart) <= AVPlayerAdapter.maxSeekOperation {
                        stateMachine.confirmSeek()
                        stateMachine.transitionState(destinationState: .seeking, time: player.currentTime())
                    }
                }
            
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
        
        let errorData = ErrorData(code: errorCode, message: error?.localizedDescription ?? "Unkown", data: error?.localizedFailureReason)
        
        if (!stateMachine.didStartPlayingVideo && stateMachine.didAttemptPlayingVideo) {
            stateMachine.onPlayAttemptFailed(withError: errorData)
        } else {
            stateMachine.error(withError: errorData, time: player.currentTime())
        }
    }

    @objc private func failedToPlayToEndTime(notification: Notification) {
        let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError
        errorOccured(error: error)
    }

    @objc private func playbackStalled(notification _: Notification) {
        stateMachine.transitionState(destinationState: .buffering, time: player.currentTime())
    }

    @objc private func timeJumped(notification _: Notification) {
        let timestamp = Date().timeIntervalSince1970Millis
        if (timestamp - stateMachine.potentialSeekStart) > AVPlayerAdapter.timeJumpedDuplicateTolerance {
            stateMachine.potentialSeekStart = timestamp
            stateMachine.potentialSeekVideoTimeStart = player.currentTime()
        }
    }

    @objc private func accessItemAdded(notification: Notification) {
        guard let item = notification.object as? AVPlayerItem, let event = item.accessLog()?.events.last else {
            return
        }
        if currentVideoBitrate == 0 {
            currentVideoBitrate = event.indicatedBitrate
        } else if currentVideoBitrate != event.indicatedBitrate {
            let previousState = stateMachine.state
            stateMachine.videoQualityChange(time: player.currentTime())
            stateMachine.transitionState(destinationState: previousState, time: player.currentTime())
            currentVideoBitrate = event.indicatedBitrate
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &AVPlayerAdapter.playerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if keyPath == #keyPath(player.rate) {
            onRateChanged(change)
        } else if keyPath == #keyPath(player.currentItem) {
            if let oldItem = change?[NSKeyValueChangeKey.oldKey] as? AVPlayerItem {
                NSLog("Current Item Changed: %@", oldItem.debugDescription)
                stopMonitoringPlayerItem(playerItem: oldItem)
            }
            if let currentItem = change?[NSKeyValueChangeKey.newKey] as? AVPlayerItem {
                NSLog("Current Item Changed: %@", currentItem.debugDescription)
                startMonitoringPlayerItem(playerItem: currentItem)
            }
        } else if keyPath == #keyPath(player.status) && player.status == .failed {
            errorOccured(error: self.player.currentItem?.error as NSError?)
        }
    }
    
    private func onRateChanged(_ change: [NSKeyValueChangeKey: Any]?) {
        let oldRate = change?[NSKeyValueChangeKey.oldKey] as? NSNumber ?? 0;
        let newRate = change?[NSKeyValueChangeKey.newKey] as? NSNumber ?? 0;

        if(newRate.floatValue == 0 && oldRate.floatValue != 0) {
            isPlaying = false
            stateMachine.pause(time: player.currentTime())
        } else if (newRate.floatValue != 0 && oldRate.floatValue == 0) {
            isPlaying = true
            stateMachine.play(time: player.currentTime())
        }
    }
    
    private func onPlayerDidChangeTime(currentTime: CMTime) {
        if currentTime == previousTime || !isPlaying {
            return
        }
        previousTime = currentTime
        emitPlayingEvent()
    }

    private func emitPlayingEvent() {
        if !isPlaying || player.currentItem?.isPlaybackLikelyToKeepUp == false {
            return;
        }
        stateMachine.playing(time: player.currentTime())
    }

    public func createEventData() -> EventData {
        let eventData: EventData = EventData(config: config, sourceMetadata: nil, impressionId: stateMachine.impressionId)
        decorateEventData(eventData: eventData)
        return eventData
    }

    private func decorateEventData(eventData: EventData) {
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
            case .hls:
                eventData.m3u8Url = urlAsset.url.absoluteString
            case .progressive:
                eventData.progUrl = urlAsset.url.absoluteString
            case .unknown:
                break
            }
        }

        // audio bitrate
        if let asset = player.currentItem?.asset {
            if !asset.tracks.isEmpty {
                let tracks = asset.tracks(withMediaType: .audio)
                if !tracks.isEmpty {
                    let desc = tracks[0].formatDescriptions[0] as! CMAudioFormatDescription
                    let basic = CMAudioFormatDescriptionGetStreamBasicDescription(desc)
                    if let sampleRate = basic?.pointee.mSampleRate {
                        eventData.audioBitrate = sampleRate
                    }
                }
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

    var currentTime: CMTime? {
        get {
            return player.currentTime()
        }
    }
}
