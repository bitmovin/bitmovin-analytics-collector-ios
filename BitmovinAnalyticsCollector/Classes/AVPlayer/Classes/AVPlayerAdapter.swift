import AVFoundation
import Foundation

class AVPlayerAdapter: NSObject, PlayerAdapter {
    static let timeJumpedDuplicateTolerance = 1000
    static let maxSeekOperation = 10000
    private static var playerKVOContext = 0
    private let stateMachine: StateMachine
    private let config: BitmovinAnalyticsConfig
    private var lastBitrate: Double = 0
    @objc private var player: AVPlayer?
    var playbackLikelyToKeepUpKeyPathObserver: NSKeyValueObservation?
    var playbackBufferEmptyObserver: NSKeyValueObservation?
    var playbackBufferFullObserver: NSKeyValueObservation?
    let lockQueue = DispatchQueue.init(label: "com.bitmovin.analytics.avplayeradapter")
    var statusObserver: NSKeyValueObservation?
    init(player: AVPlayer, config: BitmovinAnalyticsConfig, stateMachine: StateMachine) {
        self.player = player
        self.stateMachine = stateMachine
        self.config = config
        lastBitrate = 0
        super.init()
        startMonitoring()
    }

    deinit {
        if let playerItem = player?.currentItem {
            stopMonitoringPlayerItem(playerItem: playerItem)
        }
        stopMonitoring()
    }

    public func startMonitoring() {
        addObserver(self, forKeyPath: #keyPath(player.rate), options: [.new, .initial], context: &AVPlayerAdapter.playerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem), options: [.new, .initial], context: &AVPlayerAdapter.playerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.status), options: [.new, .initial], context: &AVPlayerAdapter.playerKVOContext)
    }

    public func stopMonitoring() {
        removeObserver(self, forKeyPath: #keyPath(player.rate), context: &AVPlayerAdapter.playerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem), context: &AVPlayerAdapter.playerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.status), context: &AVPlayerAdapter.playerKVOContext)
    }

    private func startMonitoringPlayerItem(playerItem: AVPlayerItem) {
        statusObserver = playerItem.observe(\.status) {[weak self] (item, _) in
            self?.playerItemStatusObserver(playerItem: item)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(accessItemAdded(notification:)), name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(timeJumped(notification:)), name: NSNotification.Name.AVPlayerItemTimeJumped, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled(notification:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(addedErrorLog(notification:)), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: playerItem)
        NotificationCenter.default.addObserver(self, selector:#selector(failedToPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)

    }

    private func stopMonitoringPlayerItem(playerItem: AVPlayerItem) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemTimeJumped, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        statusObserver?.invalidate()
    }

    private func playerItemStatusObserver(playerItem: AVPlayerItem) {
        let timestamp = Date().timeIntervalSince1970Millis
        switch playerItem.status {
        case .readyToPlay:
            lockQueue.sync {
                if stateMachine.firstReadyTimestamp != nil && stateMachine.potentialSeekStart > 0 && (timestamp - stateMachine.potentialSeekStart) <= AVPlayerAdapter.maxSeekOperation {
                    stateMachine.confirmSeek()
                    stateMachine.transitionState(destinationState: .seeking, time: player?.currentTime())
                }
            }

            guard let rate = player?.rate else {
                break
            }

            if rate == 0 {
                stateMachine.transitionState(destinationState: .paused, time: player?.currentTime())
            } else if rate > 0.0 {
                stateMachine.transitionState(destinationState: .playing, time: player?.currentTime())
            }

            break
        case .failed:
            let error = self.player?.currentItem?.error as NSError?
            let errorCode = error?.code ?? 1
            let errorMessage = error?.localizedDescription ?? "Unkown"
            
            stateMachine.transitionState(destinationState: .error, time: player?.currentTime(), data: [BitmovinAnalyticsInternal.ErrorCodeKey: errorCode, BitmovinAnalyticsInternal.ErrorMessageKey: errorMessage])
            break
        default:
            break
        }
    }

    @objc private func failedToPlayToEndTime(notification: Notification) {
        let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError
        
        let errorCode = error?.code ?? 1
        let errorMessage = error?.localizedDescription ?? "Unkown"
        
        stateMachine.transitionState(destinationState: .error, time: player?.currentTime(), data: [BitmovinAnalyticsInternal.ErrorCodeKey: errorCode, BitmovinAnalyticsInternal.ErrorMessageKey: errorMessage])
    }
    
    @objc private func addedErrorLog(notification: Notification) {
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else {
            return
        }
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else {
            return
        }
        
        let errorCode = errorLog.events.last?.errorStatusCode ?? 1
        let errorMessage = errorLog.events.last?.errorComment ?? "Unkown"
        
        stateMachine.transitionState(destinationState: .error, time: player?.currentTime(), data: [BitmovinAnalyticsInternal.ErrorCodeKey: errorCode, BitmovinAnalyticsInternal.ErrorMessageKey: errorMessage])
    }

    @objc private func playbackStalled(notification _: Notification) {
        stateMachine.transitionState(destinationState: .buffering, time: player?.currentTime())
    }

    @objc private func timeJumped(notification _: Notification) {
        let timestamp = Date().timeIntervalSince1970Millis
        if (timestamp - stateMachine.potentialSeekStart) > AVPlayerAdapter.timeJumpedDuplicateTolerance {
            stateMachine.potentialSeekStart = timestamp
            stateMachine.potentialSeekVideoTimeStart = player?.currentTime()
        }
    }

    @objc private func accessItemAdded(notification: Notification) {
        guard let item = notification.object as? AVPlayerItem, let event = item.accessLog()?.events.last else {
            return
        }
        if lastBitrate == 0 {
            lastBitrate = event.indicatedBitrate
        } else if lastBitrate != event.indicatedBitrate {
            let previousState = stateMachine.state
            stateMachine.transitionState(destinationState: .qualitychange, time: player?.currentTime())
            stateMachine.transitionState(destinationState: previousState, time: player?.currentTime())
            lastBitrate = event.indicatedBitrate
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &AVPlayerAdapter.playerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if keyPath == #keyPath(player.rate) {
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            if newRate == 0.0 && stateMachine.firstReadyTimestamp != nil {
                stateMachine.transitionState(destinationState: .paused, time: self.player?.currentTime())
            } else if newRate > 0.0 && stateMachine.firstReadyTimestamp != nil {
                stateMachine.transitionState(destinationState: .playing, time: self.player?.currentTime())
            }
        } else if keyPath == #keyPath(player.currentItem) {
            if let oldItem = change?[NSKeyValueChangeKey.oldKey] as? AVPlayerItem {
                NSLog("Current Item Changed: %@", oldItem.debugDescription)
                stopMonitoringPlayerItem(playerItem: oldItem)
            }
            if let currentItem = change?[NSKeyValueChangeKey.newKey] as? AVPlayerItem {
                NSLog("Current Item Changed: %@", currentItem.debugDescription)
                startMonitoringPlayerItem(playerItem: currentItem)
            }

        }
    }

    public func createEventData() -> EventData {
        let eventData: EventData = EventData(config: config, impressionId: stateMachine.impressionId)
        decorateEventData(eventData: eventData)
        return eventData
    }

    private func decorateEventData(eventData: EventData) {
        // Player
        eventData.player = PlayerType.avplayer.rawValue

        // Player Tech
        eventData.playerTech = "ios:avplayer"

        // Duration
        if let duration = player?.currentItem?.duration, CMTIME_IS_NUMERIC(_: duration) {
            eventData.videoDuration = Int64(CMTimeGetSeconds(duration) * BitmovinAnalyticsInternal.msInSec)
        }

        // isCasting
        eventData.isCasting = player?.isExternalPlaybackActive

        // isLive
        if let duration = player?.currentItem?.duration {
            eventData.isLive = CMTIME_IS_INDEFINITE(duration)
        }

        // version
        eventData.version = UIDevice.current.systemVersion

        // streamFormat, hlsUrl
        eventData.streamForamt = "hls"
        if let urlAsset = player?.currentItem?.asset as? AVURLAsset {
            eventData.m3u8Url = urlAsset.url.absoluteString
        }

        // audio bitrate
        if let asset = player?.currentItem?.asset {
            if asset.tracks.count > 0 {
                let tracks = asset.tracks(withMediaType: .audio)
                if tracks.count > 0 {
                    let desc = tracks[0].formatDescriptions[0] as! CMAudioFormatDescription
                    let basic = CMAudioFormatDescriptionGetStreamBasicDescription(desc)
                    if let sampleRate = basic?.pointee.mSampleRate {
                        eventData.audioBitrate = sampleRate
                    }
                }
            }
        }

        // video bitrate
        eventData.videoBitrate = lastBitrate

        // videoPlaybackWidth
        if let width = player?.currentItem?.presentationSize.width {
            eventData.videoPlaybackWidth = Int(width)
        }

        // videoPlaybackHeight
        if let height = player?.currentItem?.presentationSize.height {
            eventData.videoPlaybackHeight = Int(height)
        }

        let scale = UIScreen.main.scale
        // screenHeight
        eventData.screenHeight = Int(UIScreen.main.bounds.size.height * scale)

        // screenWidth
        eventData.screenWidth = Int(UIScreen.main.bounds.size.width * scale)

        // isMuted
        if player?.volume == 0 {
            eventData.isMuted = true
        }
    }
}
