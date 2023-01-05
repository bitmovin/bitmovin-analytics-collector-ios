import Foundation
import BitmovinPlayer

class BitmovinPlayerAdapter: CorePlayerAdapter, PlayerAdapter {
    private let config: BitmovinAnalyticsConfig
    private var player: Player
    private var isStalling: Bool
    private var isSeeking: Bool
    private var isMonitoring = false
    internal var currentSourceMetadata: SourceMetadata?
    
    /// DRM certificate download time in milliseconds
    private var drmCertificateDownloadTime: Int64?
    internal var drmDownloadTime: Int64?
    private var drmType: String?
    
    private var isPlayerReady: Bool = false
    
    private var currentVideoQuality: VideoQuality? = nil

    init(player: Player, config: BitmovinAnalyticsConfig, stateMachine: StateMachine) {
        self.player = player
        self.config = config
        self.isStalling = false
        self.isSeeking = false
        super.init(stateMachine: stateMachine)
    }
    
    func initialize() {
        startMonitoring()
        shouldTransitionToStartup()
    }
    
    private func shouldTransitionToStartup() {
        let isSourceLoadedAndWillAutoPlay = player.config.playbackConfiguration.isAutoplayEnabled && player.config.sourceConfiguration.firstSourceItem != nil
        
        let isPlayingWithoutBeingTracked = player.isPlaying && !stateMachine.didStartPlayingVideo && stateMachine.state == PlayerState.ready
        
        guard isSourceLoadedAndWillAutoPlay || isPlayingWithoutBeingTracked else {
           return
        }
       
        stateMachine.play(time: currentTime)
        
        print("BitmovinPlayerAdapter shouldTransitionToStartup \n\t isAutoplayEnabled: \(player.config.playbackConfiguration.isAutoplayEnabled) \n\t isPlaying: \(player.isPlaying) \n\t stateMachine.didStartPlayingVideo: \(stateMachine.didStartPlayingVideo) \n\t isPlayingWithoutBeingTracked: \(isPlayingWithoutBeingTracked)")

    }
    
    func resetSourceState() {
        self.drmType = nil
        self.drmDownloadTime = nil
        self.drmCertificateDownloadTime = nil
    }

    func decorateEventData(eventData: EventData) {
        //PlayerType
        eventData.player = PlayerType.bitmovin.rawValue

        //PlayerTech
        eventData.playerTech = "ios:bitmovin"

        //Duration
        if !player.duration.isNaN && !player.duration.isInfinite {
            eventData.videoDuration = Int64(player.duration * BitmovinAnalyticsInternal.msInSec)
        }

        //isCasting
        let isCasting = player.isCasting || player.isAirPlayActive
        eventData.isCasting = isCasting
       
        //castTech
        if isCasting {
            eventData.castTech = player.isAirPlayActive ? CastTech.AirPlay.rawValue : CastTech.GoogleCast.rawValue
        }
        
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

        // drmType
        eventData.drmType = self.drmType
        
        // videoQuality
        if let videoQuality = currentVideoQuality ?? player.videoQuality {
            eventData.videoBitrate = Double(videoQuality.bitrate)
            eventData.videoPlaybackWidth = Int(videoQuality.width)
            eventData.videoPlaybackHeight = Int(videoQuality.height)
            eventData.videoCodec = videoQuality.codec
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
    }

    func startMonitoring() {
        if isMonitoring {
            stopMonitoring()
        }
        isMonitoring = true
        player.add(listener: self)
    }

    override func stopMonitoring() {
        guard isMonitoring else {
            return
        }
        player.remove(listener: self)
        isStalling = false
    }
    
    var currentTime: CMTime? {
        get {
            return Util.timeIntervalToCMTime(_: player.currentTime)
        }
    }
}

extension BitmovinPlayerAdapter: PlayerListener {
    func onPlay(_ event: PlayEvent) {
        stateMachine.play(time: nil)
        
        if (isStalling && stateMachine.state != .seeking && stateMachine.state != .buffering) {
             stateMachine.transitionState(destinationState: .buffering, time: Util.timeIntervalToCMTime(_: player.currentTime))
        }
    }
    
    func onPlaying(_ event: PlayingEvent) {
        if (!isSeeking && !isStalling) {
            stateMachine.playing(time: Util.timeIntervalToCMTime(_: player.currentTime))
        }
    }
    
    func onTimeChanged(_ event: TimeChangedEvent) {
        guard player.isPlaying && !isSeeking && !isStalling else {
            return
        }
        
        stateMachine.playing(time: currentTime)
    }

    func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        stateMachine.ad(time: currentTime)
    }
    
    func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        stateMachine.adFinished()
    }
    
    func onPaused(_ event: PausedEvent) {
        isSeeking = false
        
        if player.isAd {
            stateMachine.ad(time: currentTime)
        } else {
            stateMachine.pause(time: currentTime)
        }
    }

    func onReady(_ event: ReadyEvent) {
        self.isPlayerReady = true
    }

    func onStallStarted(_ event: StallStartedEvent) {
        isStalling = true
        stateMachine.transitionState(destinationState: .buffering, time: Util.timeIntervalToCMTime(_: player.currentTime))
        
    }

    func onStallEnded(_ event: StallEndedEvent) {
        isStalling = false
        transitionToPausedOrBufferingOrPlaying()
    }

    func onSeek(_ event: SeekEvent) {
        isSeeking = true
        stateMachine.transitionState(destinationState: .seeking, time: Util.timeIntervalToCMTime(_: player.currentTime))
    }

    func onDownloadFinished(_ event: DownloadFinishedEvent) {
        let downloadTimeInMs = event.downloadTime.milliseconds

        switch event.downloadType {
        case BMPHttpRequestTypeDrmCertificateFairplay:
            // This request is the first that happens when initializing the DRM system
            self.drmCertificateDownloadTime = downloadTimeInMs
        case BMPHttpRequestTypeDrmLicenseFairplay:
            self.drmDownloadTime = (self.drmCertificateDownloadTime ?? 0) + (downloadTimeInMs ?? 0)
            self.drmType = DrmType.fairplay.rawValue
            self.drmCertificateDownloadTime = nil
        default:
            return
        }
    }

    func didVideoBitrateChange(old: VideoQuality?, new: VideoQuality?) -> Bool {
        return old?.bitrate != new?.bitrate
    }

    func onVideoDownloadQualityChanged(_ event: VideoDownloadQualityChangedEvent) {
        // no quality change if quality didn't change
        let videoBitrateDidChange = didVideoBitrateChange(old: event.videoQualityOld, new: event.videoQualityNew)
        guard videoBitrateDidChange else {
            return
        }
        
        // if nil we assume that previous quality is videoQualityOld
        if currentVideoQuality == nil {
            currentVideoQuality = event.videoQualityOld
        }
        
        stateMachine.videoQualityChange(time: currentTime){ [weak self] in
            self?.currentVideoQuality = event.videoQualityNew
        }
    }
    
    // No check if audioBitrate changes because no data available
    func onAudioChanged(_ event: AudioChangedEvent) {
        stateMachine.audioQualityChange(time: currentTime)
    }

    func onSeeked(_ event: SeekedEvent) {
        isSeeking = false
        if (!isStalling) {
            transitionToPausedOrBufferingOrPlaying()
        }
    }

    func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        stateMachine.transitionState(destinationState: .paused, time: Util.timeIntervalToCMTime(_: player.duration))
        stateMachine.disableHeartbeat()
    }

    func onError(_ event: ErrorEvent) {
        let errorData = ErrorData(code: Int(event.code), message: event.message, data: nil)
        if (!stateMachine.didStartPlayingVideo && stateMachine.didAttemptPlayingVideo) {
            stateMachine.onPlayAttemptFailed(withReason:VideoStartFailedReason.playerError, withError: errorData)
        } else {
            stateMachine.error(withError: errorData, time: Util.timeIntervalToCMTime(_: player.currentTime))
        }
    }

    func transitionToPausedOrBufferingOrPlaying() {
        if(!stateMachine.didStartPlayingVideo) {
            return
        }
        
        if isStalling {
            // Player reports isPlaying=true although onStallEnded has not been called yet -- still stalling
            stateMachine.transitionState(destinationState: .buffering, time: Util.timeIntervalToCMTime(_: player.currentTime))
        } else if player.isPaused {
            stateMachine.transitionState(destinationState: .paused, time: Util.timeIntervalToCMTime(_: player.currentTime))
        } else {
            stateMachine.transitionState(destinationState: .playing, time: Util.timeIntervalToCMTime(_: player.currentTime))
        }
    }
    
    func onSourceLoaded(_ event: SourceLoadedEvent) {
        if(player.config.playbackConfiguration.isAutoplayEnabled && !stateMachine.didAttemptPlayingVideo) {
            stateMachine.play(time: currentTime)
        }
    }
    
    func onSourceWillUnload(_ event: SourceWillUnloadEvent) {
        if (!stateMachine.didStartPlayingVideo && stateMachine.didAttemptPlayingVideo) {
            stateMachine.onPlayAttemptFailed(withReason: VideoStartFailedReason.pageClosed)
        }
    }
    
    func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        stateMachine.reset()
    }
    
    func onSubtitleChanged(_ event: SubtitleChangedEvent) {
        guard stateMachine.state == .paused || stateMachine.state == .playing else {
            return
        }
        stateMachine.transitionState(destinationState: .subtitlechange, time: Util.timeIntervalToCMTime(_: player.currentTime))
        transitionToPausedOrBufferingOrPlaying()
    }

}
