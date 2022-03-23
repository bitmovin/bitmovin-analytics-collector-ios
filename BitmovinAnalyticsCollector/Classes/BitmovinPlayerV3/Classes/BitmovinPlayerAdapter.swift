import BitmovinPlayer
#if SWIFT_PACKAGE
import BitmovinCollectorCore
#endif

internal class BitmovinPlayerAdapter: CorePlayerAdapter, PlayerAdapter {
    private let config: BitmovinAnalyticsConfig
    private var player: Player
    private var sourceMetadataProvider: SourceMetadataProvider<Source>
    private var isStalling: Bool
    private var isSeeking: Bool
    private var isMonitoring = false
    
    // To track the first source, we need to listen to the `onSourceLoad` event, but
    // only for the first time after the `onPlayerActive` event. For all subsequent sources,
    // we use the `onPlaylistTransition` event and don't want to listen to `onSourceLoad`, as
    // it might already be fired in the background during the first source.
    private var didEmitSourceLoadAfterPlayerActive: Bool = false
    
    /// DRM certificate download time in milliseconds
    private var drmCertificateDownloadTime: Int64?
    internal var drmDownloadTime: Int64?
    
    private var overrideCurrentSource: Source? = nil
    
    private var previousTime: TimeInterval = TimeInterval.nan
    
    private var currentSource: Source? {
        get {
            return overrideCurrentSource ?? player.source
        }
    }
    
    var currentSourceMetadata: SourceMetadata? {
        get {
            return sourceMetadataProvider.get(source: currentSource)
        }
    }
    
    init(player: Player, config: BitmovinAnalyticsConfig, stateMachine: StateMachine, sourceMetadataProvider:  SourceMetadataProvider<Source>) {
        self.player = player
        self.config = config
        self.isStalling = false
        self.isSeeking = false
        self.sourceMetadataProvider = sourceMetadataProvider
        super.init(stateMachine: stateMachine)
        resetSourceState()
    }
    
    deinit {
        sourceMetadataProvider.clear()
    }
    
    func initialize() {
        startMonitoring()
        shouldTransitionToStartup()
    }
    
    private func shouldTransitionToStartup(){
        let isSourceLoadedAndWillAutoPlay = player.config.playbackConfig.isAutoplayEnabled && player.source != nil

        let isPlayingWithoutBeingTracked = player.isPlaying && !stateMachine.didStartPlayingVideo && stateMachine.state == PlayerState.ready
        
        guard isSourceLoadedAndWillAutoPlay || isPlayingWithoutBeingTracked else {
            return
        }
        
        stateMachine.play(time: currentTime)

        print("BitmovinPlayerAdapter shouldTransitionToStartup \n\t isAutoplayEnabled: \(player.config.playbackConfig.isAutoplayEnabled) \n\t isPlaying: \(player.isPlaying) \n\t isPaused: \(player.isPaused) \n\t isSourceLoadedAndWillAutoPlay: \(isSourceLoadedAndWillAutoPlay) \n\t isPlayingWithoutBeingTracked: \(isPlayingWithoutBeingTracked) \n\t source \n\t\t loadingState \(String(describing: player.source?.loadingState.rawValue)) \n\t\t isActive: \(String(describing: player.source?.isActive)) \n\t\t duration: \(String(describing: player.source?.duration))  ")
    }
    
    func resetSourceState() {
        previousTime = player.currentTime
        overrideCurrentSource = player.source
        drmDownloadTime = nil
        drmCertificateDownloadTime = nil
    }

    func decorateEventData(eventData: EventData) {
        //PlayerType
        eventData.player = PlayerType.bitmovin.rawValue

        //PlayerTech
        eventData.playerTech = "ios:bitmovin"

        let isCasting = player.isCasting || player.isAirPlayActive
        eventData.isCasting = isCasting
       
        //castTech
        if isCasting {
            eventData.castTech = player.isAirPlayActive ? CastTech.AirPlay.rawValue : CastTech.GoogleCast.rawValue
        }
        
        //version
        if let sdkVersion = BitmovinPlayerUtil.playerVersion() {
            eventData.version = PlayerType.bitmovin.rawValue + "-" + sdkVersion
        }
        
        let fallbackIsLive = currentSourceMetadata?.isLive ?? config.isLive
        
        if let source = currentSource{
            let sourceConfig = source.sourceConfig
            // streamFormat & urls
            switch sourceConfig.type {
                case SourceType.dash:
                    eventData.streamFormat = StreamType.dash.rawValue
                    eventData.mpdUrl = sourceConfig.url.absoluteString
                case SourceType.hls:
                    eventData.streamFormat = StreamType.hls.rawValue
                    eventData.m3u8Url = sourceConfig.url.absoluteString
                case SourceType.progressive:
                    eventData.streamFormat = StreamType.progressive.rawValue
                    eventData.progUrl = sourceConfig.url.absoluteString
                default: break;
            }
            
            // isLive & duration
            let duration = source.duration
            if (duration == 0) {
                eventData.isLive = fallbackIsLive
            } else {
                if (duration.isInfinite) {
                    eventData.isLive = true;
                } else {
                    eventData.isLive = false;
                    eventData.videoDuration = duration.milliseconds ?? 0
                }
            }
            
            // drmType
            if let drmConfig = sourceConfig.drmConfig {
                if (drmConfig is WidevineConfig) {
                    eventData.drmType = DrmType.widevine.rawValue
                } else if (drmConfig is PlayReadyConfig) {
                    eventData.drmType = DrmType.playready.rawValue
                } else if (drmConfig is FairplayConfig) {
                    eventData.drmType = DrmType.fairplay.rawValue
                } else if (drmConfig is ClearKeyConfig) {
                    eventData.drmType = DrmType.clearkey.rawValue
                }
            }
        } else {
            // player active Source is not available
            eventData.isLive = fallbackIsLive
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
    
    func onErrorEvent(_ errorData: ErrorData) {
        if (!stateMachine.didStartPlayingVideo && stateMachine.didAttemptPlayingVideo) {
            stateMachine.onPlayAttemptFailed(withError: errorData)
        } else {
            stateMachine.error(withError: errorData, time: Util.timeIntervalToCMTime(_: player.currentTime))
        }
    }
    
    private var isEventRelevantForCurrentSource: Bool {
        get {
            let isRelevant = player.source === overrideCurrentSource
            if(!isRelevant) {
                print("Event isn't relevant for current source.")
            }
            return isRelevant
        }
    }
}

extension BitmovinPlayerAdapter: PlayerListener {
    func onPlay(_ event: PlayEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        print("BitmovinAdapter: onPlay isPlaying: \(player.isPlaying) isPaused: \(player.isPaused) isStalling: \(isStalling)")
        stateMachine.play(time: nil)
        
        if (isStalling && stateMachine.state != .seeking && stateMachine.state != .buffering) {
             stateMachine.transitionState(destinationState: .buffering, time: Util.timeIntervalToCMTime(_: player.currentTime))
        }
    }
    
    func onTimeChanged(_ event: TimeChangedEvent, player: Player) {
        print("BitmovinAdapter: onTimeChanged \(event.currentTime) isPlaying: \(player.isPlaying) isPaused: \(player.isPaused) isStalling: \(isStalling) isSeeking: \(isSeeking)")
        
        // When seeking between sources, there might be onTimeChanged events that
        // do not indicate actual playback (from the last time in the old source to
        // 0.0 in the new source for example)
        guard event.currentTime != previousTime else {
            print("Ignoring onTimeChanged, time didn't change.")
            return
        }
        
        previousTime = event.currentTime
        
        if (player.isPlaying && !isSeeking && !isStalling) {
            stateMachine.playing(time: currentTime)
        }
    }
    
    func onPlaying(_ event: PlayingEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        print("BitmovinAdapter: onPlaying isPlaying: \(player.isPlaying) isPaused: \(player.isPaused) isStalling: \(isStalling)")
        if (!isSeeking && !isStalling) {
            stateMachine.playing(time: currentTime)
        }
    }

    func onAdBreakStarted(_ event: AdBreakStartedEvent, player: Player) {
        stateMachine.transitionState(destinationState: .ad, time: currentTime)
    }
    
    func onAdBreakFinished(_ event: AdBreakFinishedEvent, player: Player) {
        stateMachine.transitionState(destinationState: .adFinished, time: currentTime)
    }
    
    func onPaused(_ event: PausedEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        isSeeking = false
        stateMachine.pause(time: currentTime)
    }

    func onStallStarted(_ event: StallStartedEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        print("BitmovinAdapter: onStallStarted \(player.currentTime) isPlaying: \(player.isPlaying) isPaused: \(player.isPaused)")
        isStalling = true
        stateMachine.transitionState(destinationState: .buffering, time: Util.timeIntervalToCMTime(_: player.currentTime))
        
    }

    func onStallEnded(_ event: StallEndedEvent, player: Player) {
        print("BitmovinAdapter: onStallEnded \(player.currentTime) isPlaying: \(player.isPlaying) isPaused: \(player.isPaused)")
        isStalling = false
        transitionToPausedOrBufferingOrPlaying()
    }

    func onSeek(_ event: SeekEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        print("BitmovinAdapter: onSeek \(player.currentTime) isPlaying: \(player.isPlaying) isPaused: \(player.isPaused)")
        isSeeking = true
        stateMachine.transitionState(destinationState: .seeking, time: Util.timeIntervalToCMTime(_: player.currentTime))
    }

    func onDownloadFinished(_ event: DownloadFinishedEvent, player: Player) {
        let downloadTimeInMs = event.downloadTime.milliseconds

        switch event.downloadType {
        case BMPHttpRequestTypeDrmCertificateFairplay:
            // This request is the first that happens when initializing the DRM system
            self.drmCertificateDownloadTime = downloadTimeInMs
        case BMPHttpRequestTypeDrmLicenseFairplay:
            self.drmDownloadTime = (self.drmCertificateDownloadTime ?? 0) + (downloadTimeInMs ?? 0)
            self.drmCertificateDownloadTime = nil
        default:
            return
        }
    }

    func didVideoBitrateChange(old: VideoQuality?, new: VideoQuality?) -> Bool {
        return old?.bitrate != new?.bitrate
    }

    func onVideoDownloadQualityChanged(_ event: VideoDownloadQualityChangedEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        // no quality change before video started
        guard stateMachine.didStartPlayingVideo else {
            return
        }
        
        // no quality change during buffering and seeking
        guard !isStalling && !isSeeking else {
            return
        }
        
        // no quality change if quality didn't change
        let videoBitrateDidChange = didVideoBitrateChange(old: event.videoQualityOld, new: event.videoQualityNew)
        guard videoBitrateDidChange else {
            return
        }
        
        stateMachine.videoQualityChange(time: currentTime)
        transitionToPausedOrBufferingOrPlaying()
    }
    
    // No check if audioBitrate changes because no data available
    func onAudioChanged(_ event: AudioChangedEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        // no audio change before video started
        guard stateMachine.didStartPlayingVideo else {
            return
        }
        
        // no audio change during buffering and seeking
        guard !isStalling && !isSeeking else {
            return
        }
        
        stateMachine.audioQualityChange(time: currentTime)
        transitionToPausedOrBufferingOrPlaying()
    }

    func onSeeked(_ event: SeekedEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        print("BitmovinAdapter: onSeeked \(player.currentTime) isPlaying: \(player.isPlaying) isPaused: \(player.isPaused)")
        isSeeking = false
        if (!isStalling) {
            transitionToPausedOrBufferingOrPlaying()
        }
    }

    func onPlaybackFinished(_ event: PlaybackFinishedEvent, player: Player) {
        stateMachine.transitionState(destinationState: .paused, time: Util.timeIntervalToCMTime(_: player.duration))
        stateMachine.reset()
    }

    func onPlayerError(_ event: PlayerErrorEvent, player: Player) {
        let errorData = ErrorData(code: Int(event.code.rawValue), message: event.message, data: nil)
        onErrorEvent(errorData)
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
    
    
    func onSourceMetadataChanged(_ event: SourceMetadataChangedEvent, player: Player) {
        print("BitmovinAdapter: onSourceMetadataChanged \(event.name)")
    }
    
    func onPlayerActive(_ event: PlayerActiveEvent, player: Player) {
        didEmitSourceLoadAfterPlayerActive = false
    }
    
    func onSourceLoad(_ event: SourceLoadEvent, player: Player) {
        if(!didEmitSourceLoadAfterPlayerActive) {
            didEmitSourceLoadAfterPlayerActive = true
            overrideCurrentSource = event.source
        }
        if(player.config.playbackConfig.isAutoplayEnabled && !stateMachine.didAttemptPlayingVideo) {
            stateMachine.play(time: currentTime)
        }
        print("BitmovinAdapter: onSourceLoad \(event.source.sourceConfig.url)")
    }
    
    func onSourceLoaded(_ event: SourceLoadedEvent, player: Player) {
        print("BitmovinAdapter: onSourceLoaded \(event.source.sourceConfig.url)")
    }
    
    func onSourceUnload(_ event: SourceUnloadEvent, player: Player) {
        print("BitmovinAdapter: onSourceUnload")
        if (!stateMachine.didStartPlayingVideo && stateMachine.didAttemptPlayingVideo) {
            stateMachine.onPlayAttemptFailed(withReason: VideoStartFailedReason.pageClosed)
        }
    }
    
    func onSourceUnloaded(_ event: SourceUnloadedEvent, player: Player) {
        stateMachine.reset()
    }
    
    func onPlaylistTransition(_ event: PlaylistTransitionEvent, player: Player) {
        print("------------- \nBitmovinAdapter: onPlaylistTransition \(player.currentTime) \n\t isPlaying: \(player.isPlaying) \n\t isPaused: \(player.isPaused) \n\t from: \(event.from.sourceConfig.url) \n\t to: \(event.to.sourceConfig.url)")
        overrideCurrentSource = event.from
        let previousVideoDuration = Util.timeIntervalToCMTime(_: event.from.duration)
        let nextVideotimeStart = self.currentTime
        let shouldStartup = player.isPlaying
        stateMachine.sourceChange(previousVideoDuration, nextVideotimeStart, shouldStartup)
        overrideCurrentSource = event.to
    }
    
    func onSubtitleChanged(_ event: SubtitleChangedEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        guard stateMachine.state == .paused || stateMachine.state == .playing else {
            return
        }
        stateMachine.transitionState(destinationState: .subtitlechange, time: Util.timeIntervalToCMTime(_: player.currentTime))
        transitionToPausedOrBufferingOrPlaying()
    }
}

extension BitmovinPlayerAdapter: SourceListener {
    func onSourceError(_ event: SourceErrorEvent, player: Player) {
        let errorData = ErrorData(code: Int(event.code.rawValue), message: event.message, data: nil)
        onErrorEvent(errorData)
    }
}
