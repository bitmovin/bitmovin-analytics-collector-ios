import AVFoundation
import Foundation
import UIKit
#if SWIFT_PACKAGE
import CoreCollector
#endif

class AVPlayerAdapter: CorePlayerAdapter, PlayerAdapter {
    static let periodicTimeObserverIntervalSeconds = 0.2
    static let minSeekDeltaSeconds = periodicTimeObserverIntervalSeconds + 0.3
    
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
    private let downloadSpeedDetectionService: DownloadSpeedDetectionService
    private let downloadSpeedMeter: DownloadSpeedMeter
    private let manipulator: AVPlayerEventDataManipulator
    
    init(player: AVPlayer,
         stateMachine: StateMachine,
         errorHandler: ErrorHandler,
         bitrateDetectionService: BitrateDetectionService,
         playbackTypeDetectionService: PlaybackTypeDetectionService,
         downloadSpeedDetectionService: DownloadSpeedDetectionService,
         downloadSpeedMeter: DownloadSpeedMeter,
         manipulator: AVPlayerEventDataManipulator
    ) {
        self.player = player
        self.errorHandler = errorHandler
        self.bitrateDetectionService = bitrateDetectionService
        self.downloadSpeedMeter = downloadSpeedMeter
        self.downloadSpeedDetectionService = downloadSpeedDetectionService
        self.playbackTypeDetectionService = playbackTypeDetectionService
        self.manipulator = manipulator
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
        playbackTypeDetectionService.resetSourceState()
        bitrateDetectionService.resetSourceState()
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
        
        let accessLogProvider = AVPlayerAccessLogProvider(playerItem: playerItem)
        bitrateDetectionService.startMonitoring(accessLogProvider: accessLogProvider)
        bitrateDetectionServiceKVO = bitrateDetectionService.observe(\.videoBitrate, options: [.new, .old]) { [weak self] _, change in
            self?.onVideoQualityChange(newVideoBitrate: change.newValue ?? nil)
        }
        
        downloadSpeedDetectionService.startMonitoring(accessLogProvider: accessLogProvider)
    }

    private func stopMonitoringPlayerItem(playerItem: AVPlayerItem) {
        NotificationCenter.default.removeObserver(self, name: AVPlayerItem.timeJumpedNotification, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playerItemStatusObserver?.invalidate()
        
        playbackTypeDetectionService.stopMonitoring(playerItem: playerItem)
        
        bitrateDetectionService.stopMonitoring()
        bitrateDetectionServiceKVO?.invalidate()
        bitrateDetectionServiceKVO = nil
        
        downloadSpeedDetectionService.stopMonitoring()
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
    @objc private func observeTimeJumped(notification: Notification) {
        // ignores this event when there was no playing yet
        guard let prevPlayerTime = previousTime else {
            return
        }
        
        // if time dif between previous tracked playerTime and
        // the current playerTime is bigger than the minimal seek time, it's a seek
        let timeDelta = abs(CMTimeGetSeconds(player.currentTime() - prevPlayerTime))
        if timeDelta < AVPlayerAdapter.minSeekDeltaSeconds {
            return
        }
        
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
