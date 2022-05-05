import AVFoundation
import Foundation
import UIKit
#if SWIFT_PACKAGE
import CoreCollector
#endif

class AVPlayerAdapter: CorePlayerAdapter, PlayerAdapter {
    static let periodicTimeObserverIntervalSeconds = 0.2
    static let minSeekDeltaSeconds = periodicTimeObserverIntervalSeconds + 0.3
    
    private let config: BitmovinAnalyticsConfig
    @objc private let player: AVPlayer
    
    private var isMonitoring = false
    internal var currentSourceMetadata: SourceMetadata?
    
    // KVO references
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var playerKVOList: Array<NSKeyValueObservation> = Array()
    private var bitrateDetectionServiceKVO: NSKeyValueObservation?
    
    // used for time tracking
    private var periodicTimeObserver: Any?
    private var previousTime: CMTime?
    private var previousTimestamp: Int64 = 0
    
    // Helper classes
    private let errorHandler: ErrorHandler
    private let bitrateDetectionService: BitrateDetectionService
    private let playbackTypeDetectionService: PlaybackTypeDetectionService
    private let manipulator: AVPlayerEventDataManipulator
    
    init(player: AVPlayer, config: BitmovinAnalyticsConfig, stateMachine: StateMachine) {
        self.player = player
        self.config = config
        self.errorHandler = ErrorHandler()
        self.bitrateDetectionService = BitrateDetectionService(bitrateLogProvider: AVPlayerBitrateLogProvider(player: player))
        self.playbackTypeDetectionService = PlaybackTypeDetectionService(player: player)
        self.manipulator = AVPlayerEventDataManipulator(player: player, playbackTypeDetectionService: playbackTypeDetectionService)
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
        manipulator.resetSourceState()
        previousTime = nil
        previousTimestamp = 0
    }
    
    func decorateEventData(eventData: EventData) {
        manipulator.manipulate(eventData: eventData)
    }
    
    // Monitoring
    public func startMonitoring() {
        if isMonitoring  {
            stopMonitoring()
        }
        isMonitoring = true
        
        periodicTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(AVPlayerAdapter.periodicTimeObserverIntervalSeconds, preferredTimescale: Int32(NSEC_PER_SEC)), queue: .main) { [weak self] playerTime in
            self?.onPlayerTimeChanged(playerTime)
        }
        
        playerKVOList.append(player.observe(\.status, options: [.new, .old, .initial]) {[weak self] (player, _) in
            self?.onPlayerStatusChanged(player)
        })
        
        playerKVOList.append(player.observe(\.rate, options: [.new, .old, .initial]) {[weak self] (player, change) in
            self?.onPlayerRateChanged(old: change.oldValue, new: change.newValue)
        })
        
        playerKVOList.append(player.observe(\.currentItem, options: [.new, .old, .initial]) {[weak self] (player, change) in
            self?.onPlayerCurrentItemChange(old: change.oldValue ?? nil, new: change.newValue ?? nil)
        })
        
        bitrateDetectionService.startMonitoring()
        bitrateDetectionServiceKVO = bitrateDetectionService.observe(\.videoBitrate, options: [.new, .old]) { [weak self] _, change in
            self?.onVideoQualityChange(newVideoBitrate: change.newValue ?? nil)
        }
    }

    override public func stopMonitoring() {
        guard isMonitoring else {
            return
        }
        isMonitoring = false
        
        if let playerItem = player.currentItem {
            stopMonitoringPlayerItem(playerItem: playerItem)
        }
        
        if let timeObserver = periodicTimeObserver {
            player.removeTimeObserver(timeObserver)
            self.periodicTimeObserver = nil
        }
        
        for kvo in playerKVOList {
            kvo.invalidate()
        }
        playerKVOList.removeAll()
        
        bitrateDetectionServiceKVO?.invalidate()
        bitrateDetectionServiceKVO = nil
        
        resetSourceState()
    }

    private func startMonitoringPlayerItem(playerItem: AVPlayerItem) {
        playerItemStatusObserver = playerItem.observe(\.status) {[weak self] (item, _) in
            self?.onPlayerItemStatusChanged(item)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(observeTimeJumped(notification:)), name: AVPlayerItem.timeJumpedNotification, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(observePlaybackStalled(notification:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(observeFailedToPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(observeDidPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        manipulator.updateDrmPerformanceInfo(playerItem)
        playbackTypeDetectionService.startMonitoring(playerItem: playerItem)
    }

    private func stopMonitoringPlayerItem(playerItem: AVPlayerItem) {
        NotificationCenter.default.removeObserver(self, name: AVPlayerItem.timeJumpedNotification, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playerItemStatusObserver?.invalidate()
        playbackTypeDetectionService.stopMonitoring(playerItem: playerItem)
    }

    // AVPlayerItem KVOs
    private func onPlayerItemStatusChanged(_ playerItem: AVPlayerItem) {
        switch playerItem.status {
            case .failed:
                errorOccured(error: playerItem.error as NSError?)

            default:
                break
        }
    }
    
    // AVPlayer KVOs
    private func onPlayerStatusChanged(_ player: AVPlayer) {
        switch player.status {
            case .failed:
                errorOccured(error: player.currentItem?.error as NSError?)
            
            default:
                break
        }
    }
    
    private func onPlayerRateChanged(old: Float?, new: Float?) {
        guard let oldRate = old, let newRate = new else {
            return
        }
        
        if(newRate == 0 && oldRate != 0) {
            stateMachine.pause(time: player.currentTime())
        } else if (newRate != 0 && oldRate == 0 && self.player.currentItem != nil) {
            stateMachine.play(time: player.currentTime())
        }
    }
    
    private func onPlayerCurrentItemChange(old: AVPlayerItem?, new: AVPlayerItem?) {
        if let oldItem = old {
            NSLog("Current Item Changed: %@", oldItem.debugDescription)
            stopMonitoringPlayerItem(playerItem: oldItem)
        }
        
        if let newItem = new {
            NSLog("Current Item Changed: %@", newItem.debugDescription)
            startMonitoringPlayerItem(playerItem: newItem)
            if player.rate > 0 {
                stateMachine.play(time: player.currentTime())
            }
        }
    }
    
    private func onPlayerTimeChanged(_ playerTime: CMTime){
        checkSeek(playerTime)
        checkPlaying(playerTime)
        previousTime = playerTime
        previousTimestamp = Date().timeIntervalSince1970Millis
    }
    
    // AVPlayer Notifications
    @objc private func observeFailedToPlayToEndTime(notification: Notification) {
        let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError
        errorOccured(error: error)
    }

    @objc private func observeDidPlayToEndTime(notification: Notification) {
        stateMachine.pause(time: player.currentTime())
    }

    @objc private func observePlaybackStalled(notification _: Notification) {
        stateMachine.transitionState(destinationState: .buffering, time: player.currentTime())
    }
    
    // if seek into unbuffered area (no data) we get this event and know that it's a seek
    @objc private func observeTimeJumped(notification _: Notification) {
        stateMachine.transitionState(destinationState: .seeking, time: previousTime)
    }
    
    // Helper methods
    
    private func onVideoQualityChange(newVideoBitrate: Double?) {
        guard let videoBitrate = newVideoBitrate else {
            return
        }
        
        if manipulator.currentVideoQuality == nil {
            manipulator.updateVideoBitrate(videoBitrate: videoBitrate)
            return
        }
        
        stateMachine.videoQualityChange(time: player.currentTime()) { [weak self] in
            self?.manipulator.updateVideoBitrate(videoBitrate: videoBitrate)
        }
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
    
    var currentTime: CMTime? {
        get {
            return player.currentTime()
        }
    }
    
    var drmDownloadTime: Int64? {
        get {
            return manipulator.drmDownloadTime
        }
    }
}
