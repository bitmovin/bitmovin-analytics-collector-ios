import Foundation
import BitmovinPlayer

class BitmovinPlayerAdapter: NSObject, PlayerAdapter {
    private let stateMachine: StateMachine
    private let config: BitmovinAnalyticsConfig
    private var player: BitmovinPlayer
    private var errorCode: Int?
    private var errorDescription: String?
    private var videoStartFailed: Bool
    private var videoStartFailedReason: String?
    private var isVideoStartTimerActive: Bool
    private var didVideoPlay: Bool
    private var isPlayerReady: Bool
    private var didAttemptPlay: Bool
    
    private let videoStartTimeoutSeconds: TimeInterval = 600

    init(player: BitmovinPlayer, config: BitmovinAnalyticsConfig, stateMachine: StateMachine) {
        self.player = player
        self.stateMachine = stateMachine
        self.config = config
        self.isPlayerReady = false
        self.didAttemptPlay = false
        self.didVideoPlay = false
        self.isVideoStartTimerActive = false
        self.videoStartFailedReason = nil
        self.videoStartFailed = false
        super.init()
        startMonitoring()
    }

    func createEventData() -> EventData {
        let eventData: EventData = EventData(config: config, impressionId: stateMachine.impressionId)
        decorateEventData(eventData: eventData)
        return eventData
    }

    deinit {
        self.isPlayerReady = false
        stopMonitoring()
    }

    private func decorateEventData(eventData: EventData) {
        //PlayerType
        eventData.player = PlayerType.bitmovin.rawValue

        //PlayerTech
        eventData.playerTech = "ios:bitmovin"

        //ErrorCode
        eventData.errorCode = errorCode
        eventData.errorMessage = errorDescription

        //Duration
        if !player.duration.isNaN && !player.duration.isInfinite {
            eventData.videoDuration = Int64(player.duration * BitmovinAnalyticsInternal.msInSec)
        }

        //isCasting
        eventData.isCasting = player.isCasting

        //isLive
        eventData.isLive = self.isPlayerReady ? player.isLive : self.config.isLive

        //version
        if let sdkVersion = BitmovinPlayerUtil.playerVersion() {
            eventData.version = PlayerType.bitmovin.rawValue + "-" + sdkVersion
        }
        
        let sourceUrl = player.config.sourceItem?.url(forType: player.streamType)
        switch player.streamType {
        case .DASH:
            eventData.streamFormat = StreamType.dash.rawValue
            eventData.mpdUrl = sourceUrl?.absoluteString
        case .HLS:
            eventData.streamFormat = StreamType.hls.rawValue
            eventData.m3u8Url = sourceUrl?.absoluteString
        case .progressive:
            eventData.streamFormat = StreamType.progressive.rawValue
            eventData.progUrl = sourceUrl?.absoluteString
        default: break;
        }

        // videoBitrate
        if let bitrate = player.videoQuality?.bitrate {
            eventData.videoBitrate = Double(bitrate)
        }

        // videoPlaybackWidth
        if let videoPlaybackWidth = player.videoQuality?.width {
            eventData.videoPlaybackWidth = Int(videoPlaybackWidth)
        }

        // videoPlaybackHeight
        if let videoPlaybackHeight = player.videoQuality?.height {
            eventData.videoPlaybackHeight = Int(videoPlaybackHeight)
        }
        
        // videoCodec
        if let videoCodec = player.videoQuality?.codec {
            eventData.videoCodec = String(videoCodec)
        }

        let scale = UIScreen.main.scale
        // screenHeight
        eventData.screenHeight = Int(UIScreen.main.bounds.size.height * scale)

        // screenWidth
        eventData.screenWidth = Int(UIScreen.main.bounds.size.width * scale)

        // isMuted
        eventData.isMuted = player.isMuted
        
        eventData.subtitleEnabled = player.subtitle.identifier != "off"
        if eventData.subtitleEnabled! {
            eventData.subtitleLanguage = player.subtitle.language ?? player.subtitle.label
        }

        eventData.audioLanguage = player.audio?.language
        
        if (videoStartFailed) {
            eventData.videoStartFailed = videoStartFailed
            eventData.videoStartFailedReason = videoStartFailedReason ?? VideoStartFailedReason.unknown
            videoStartFailed = false
            videoStartFailedReason = nil
        }
    }

    func startMonitoring() {
        player.add(listener: self)
    }

    func stopMonitoring() {
        player.remove(listener: self)
    }
    
    var currentTime: CMTime? {
        get {
            return Util.timeIntervalToCMTime(_: player.currentTime)
        }
    }
    
    func setVideoStartTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + self.videoStartTimeoutSeconds) {
            if (self.isVideoStartTimerActive)
            {
                self.onPlayAttemptFailed(withReason: VideoStartFailedReason.timeout)
            }
        }
        isVideoStartTimerActive = true
    }
    
    func clearVideoStartTimer() {
        isVideoStartTimerActive = false
    }
    
    func onPlayAttemptFailed(withReason reason: String = VideoStartFailedReason.unknown) {
        videoStartFailed = true
        videoStartFailedReason = reason
        stateMachine.transitionState(destinationState: .playAttemptFailed, time: Util.timeIntervalToCMTime(_: player.currentTime))
    }
}

extension BitmovinPlayerAdapter: PlayerListener {
    func onPlay(_ event: PlayEvent) {
        setVideoStartTimer()
        didAttemptPlay = true
        stateMachine.transitionState(destinationState: .playing, time: Util.timeIntervalToCMTime(_: player.currentTime))
    }
    
    func onPlaying(_ event: PlayingEvent) {
        clearVideoStartTimer()
        didVideoPlay = true
    }

    func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        clearVideoStartTimer()
    }
    
    func onPaused(_ event: PausedEvent) {
        stateMachine.transitionState(destinationState: .paused, time: Util.timeIntervalToCMTime(_: player.currentTime))
    }

    func onReady(_ event: ReadyEvent) {
        self.isPlayerReady = true
        transitionToPausedOrPlaying()
    }

    func onStallStarted(_ event: StallStartedEvent) {
        stateMachine.transitionState(destinationState: .buffering, time: Util.timeIntervalToCMTime(_: player.currentTime))
    }

    func onStallEnded(_ event: StallEndedEvent) {
        transitionToPausedOrPlaying()
    }

    func onSeek(_ event: SeekEvent) {
        stateMachine.transitionState(destinationState: .seeking, time: Util.timeIntervalToCMTime(_: player.currentTime))
    }

    func onVideoDownloadQualityChanged(_ event: VideoDownloadQualityChangedEvent) {
        stateMachine.transitionState(destinationState: .qualitychange, time: Util.timeIntervalToCMTime(_: player.currentTime))
        transitionToPausedOrPlaying()
    }

    func onSeeked(_ event: SeekedEvent) {
        transitionToPausedOrPlaying()
    }

    func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        stateMachine.transitionState(destinationState: .paused, time: Util.timeIntervalToCMTime(_: player.duration))
        stateMachine.disableHeartbeat()
    }

    func onError(_ event: ErrorEvent) {
        errorCode = Int(event.code)
        errorDescription = event.description
        if (!didVideoPlay) {
            videoStartFailed = true
            videoStartFailedReason = VideoStartFailedReason.playerError
        }
        stateMachine.transitionState(destinationState: .error, time: Util.timeIntervalToCMTime(_: player.currentTime))
    }

    func transitionToPausedOrPlaying() {
        if player.isPaused {
            stateMachine.transitionState(destinationState: .paused, time: Util.timeIntervalToCMTime(_: player.currentTime))
        } else {
            stateMachine.transitionState(destinationState: .playing, time: Util.timeIntervalToCMTime(_: player.currentTime))
        }
    }
    
    func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        if (!didVideoPlay && didAttemptPlay) {
            self.onPlayAttemptFailed(withReason: VideoStartFailedReason.pageClosed)
        }
        stateMachine.reset()
    }
    
    func onSubtitleChanged(_ event: SubtitleChangedEvent) {
        guard stateMachine.state == .paused || stateMachine.state == .playing else {
            return
        }
        stateMachine.transitionState(destinationState: .subtitlechange, time: Util.timeIntervalToCMTime(_: player.currentTime))
        transitionToPausedOrPlaying()
    }

    func onAudioChanged(_ event: AudioChangedEvent) {
        guard stateMachine.state == .paused || stateMachine.state == .playing else {
            return
        }
        stateMachine.transitionState(destinationState: .audiochange, time: Util.timeIntervalToCMTime(_: player.currentTime))
        transitionToPausedOrPlaying()
    }
}
