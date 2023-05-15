import BitmovinPlayerCore
import CoreCollector

internal class BitmovinPlayerAdapter: CorePlayerAdapter, PlayerAdapter, EventDataManipulator {
    private let logger = _AnalyticsLogger(className: "BitmovinPlayerAdapter")
    private final var config: BitmovinAnalyticsConfig
    private final var player: Player
    private final var sourceMetadataProvider: SourceMetadataProvider<Source>

    private var isStalling: Bool
    private var isSeeking: Bool
    private var isMonitoring = false

    // To track the first source, we need to listen to the `onSourceLoad` event, but
    // only for the first time after the `onPlayerActive` event. For all subsequent sources,
    // we use the `onPlaylistTransition` event and don't want to listen to `onSourceLoad`, as
    // it might already be fired in the background during the first source.
    private var didEmitSourceLoadAfterPlayerActive = false

    /// DRM certificate download time in milliseconds
    private var drmCertificateDownloadTime: Int64?
    internal var drmDownloadTime: Int64?

    private var overrideCurrentSource: Source?

    private var previousTime = TimeInterval.nan

    private var currentSource: Source? {
        overrideCurrentSource ?? player.source
    }

    private var currentVideoQuality: VideoQuality?

    var currentSourceMetadata: SourceMetadata? {
        sourceMetadataProvider.get(source: currentSource)
    }

    init(
        player: Player,
        config: BitmovinAnalyticsConfig,
        stateMachine: StateMachine,
        sourceMetadataProvider: SourceMetadataProvider<Source>
    ) {
        self.player = player
        self.config = config
        self.sourceMetadataProvider = sourceMetadataProvider

        self.isStalling = false
        self.isSeeking = false
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

    private func shouldTransitionToStartup() {
        let isSourceLoadedAndWillAutoPlay = player.config.playbackConfig.isAutoplayEnabled && player.source != nil

        let isPlayingWithoutBeingTracked = player.isPlaying
            && !stateMachine.didStartPlayingVideo
            && stateMachine.state == PlayerState.ready

        guard isSourceLoadedAndWillAutoPlay || isPlayingWithoutBeingTracked else {
            return
        }

        stateMachine.play(time: currentTime)

        logger.d(
        """
        shouldTransitionToStartup isAutoplayEnabled: \(player.config.playbackConfig.isAutoplayEnabled),
        isPlaying: \(player.isPlaying), isPaused: \(player.isPaused),
        isSourceLoadedAndWillAutoPlay: \(isSourceLoadedAndWillAutoPlay),
        isPlayingWithoutBeingTracked: \(isPlayingWithoutBeingTracked),
        loadingState \(String(describing: player.source?.loadingState.rawValue)),
        isActive: \(String(describing: player.source?.isActive)),
        duration: \(String(describing: player.source?.duration))
        """
        )
    }

    func resetSourceState() {
        previousTime = player.currentTime
        overrideCurrentSource = player.source
        drmDownloadTime = nil
        drmCertificateDownloadTime = nil
    }

    func manipulate(eventData: EventData) {
        // PlayerType
        eventData.player = PlayerType.bitmovin.rawValue

        // PlayerTech
        eventData.playerTech = "ios:bitmovin"

        // version
        if let sdkVersion = BitmovinPlayerUtil.playerVersion() {
            eventData.version = PlayerType.bitmovin.rawValue + "-" + sdkVersion
        }

        if let source = currentSource {
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
            default:
                break
            }

            // isLive & duration
            let duration = source.duration
            if duration != 0 {
                if duration.isInfinite {
                    eventData.isLive = true
                } else {
                    eventData.isLive = false
                    eventData.videoDuration = duration.milliseconds ?? 0
                }
            }

            // drmType
            if let drmConfig = sourceConfig.drmConfig {
                if drmConfig is WidevineConfig {
                    eventData.drmType = DrmType.widevine.rawValue
                } else if drmConfig is PlayReadyConfig {
                    eventData.drmType = DrmType.playready.rawValue
                } else if drmConfig is FairplayConfig {
                    eventData.drmType = DrmType.fairplay.rawValue
                } else if drmConfig is ClearKeyConfig {
                    eventData.drmType = DrmType.clearkey.rawValue
                }
            }
        }

        // isMuted
        eventData.isMuted = player.isMuted

        let subtitleEnabled = player.subtitle.identifier != "off"
        eventData.subtitleEnabled = subtitleEnabled
        if !subtitleEnabled {
            eventData.subtitleLanguage = player.subtitle.language ?? player.subtitle.label
        }

        eventData.audioLanguage = player.audio?.language

        // videoQuality
        if let videoQuality = currentVideoQuality ?? player.videoQuality {
            eventData.videoBitrate = Double(videoQuality.bitrate)
            eventData.videoPlaybackWidth = Int(videoQuality.width)
            eventData.videoPlaybackHeight = Int(videoQuality.height)
            eventData.videoCodec = videoQuality.codec
        }
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
        player.currentTimeMillis
    }

    func onErrorEvent(_ errorData: ErrorData) {
        if !stateMachine.didStartPlayingVideo && stateMachine.didAttemptPlayingVideo {
            stateMachine.onPlayAttemptFailed(withReason: VideoStartFailedReason.playerError, withError: errorData)
        } else {
            stateMachine.error(withError: errorData, time: player.currentTimeMillis)
        }
    }

    private var isEventRelevantForCurrentSource: Bool {
        let isRelevant = player.source === overrideCurrentSource
        if !isRelevant {
            logger.d("Event isn't relevant for current source.")
        }
        return isRelevant
    }
}

extension BitmovinPlayerAdapter: PlayerListener {
    func onPlay(_ event: PlayEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        logger.d("onPlay isPlaying: \(player.isPlaying), isPaused: \(player.isPaused), isStalling: \(isStalling)")
        stateMachine.play(time: nil)

        if isStalling && stateMachine.state != .seeking && stateMachine.state != .buffering {
             stateMachine.transitionState(destinationState: .buffering, time: player.currentTimeMillis)
        }
    }

    func onTimeChanged(_ event: TimeChangedEvent, player: Player) {

        // When seeking between sources, there might be onTimeChanged events that
        // do not indicate actual playback (from the last time in the old source to
        // 0.0 in the new source for example)
        guard event.currentTime != previousTime else {
            logger.d("Ignoring onTimeChanged, time didn't change.")
            return
        }

        previousTime = event.currentTime

        if player.isPlaying && !isSeeking && !isStalling {
            stateMachine.playing(time: currentTime)
        }
    }

    func onPlaying(_ event: PlayingEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        logger.d("onPlaying: isPlaying: \(player.isPlaying), isPaused: \(player.isPaused), isStalling: \(isStalling)")
        if !isSeeking && !isStalling {
            stateMachine.playing(time: currentTime)
        }
    }

    func onAdBreakStarted(_ event: AdBreakStartedEvent, player: Player) {
        transitionToAd()
    }

    private func transitionToAd() {
        // In this case we are not using `currentTime` or `player.currentTime`
        // because player has already change the time to the ad ones
        // previousTime is set in onTimeChanged and relates to the last tracked time of the video
        let adStartTime = CMTimeMakeWithSeconds(previousTime, preferredTimescale: Int32(NSEC_PER_SEC))
        stateMachine.ad(time: adStartTime)
    }

    func onAdBreakFinished(_ event: AdBreakFinishedEvent, player: Player) {
        stateMachine.adFinished()
    }

    func onPaused(_ event: PausedEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        isSeeking = false
        if player.isAd {
            transitionToAd()
        } else {
            stateMachine.pause(time: currentTime)
        }
    }

    func onStallStarted(_ event: StallStartedEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        logger.d("onStallStarted currentTime: \(player.currentTime), isPlaying: \(player.isPlaying), isPaused: \(player.isPaused)")
        isStalling = true
        stateMachine.transitionState(destinationState: .buffering, time: currentTime)
    }

    func onStallEnded(_ event: StallEndedEvent, player: Player) {
        logger.d("onStallEnded currentTime: \(player.currentTime), isPlaying: \(player.isPlaying), isPaused: \(player.isPaused)")
        isStalling = false
        transitionToPausedOrBufferingOrPlaying()
    }

    func onSeek(_ event: SeekEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        logger.d("onSeek currentTime: \(player.currentTime), isPlaying: \(player.isPlaying), isPaused: \(player.isPaused)")
        isSeeking = true
        stateMachine.seek(time: currentTime)
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
        old?.bitrate != new?.bitrate
    }

    func onVideoDownloadQualityChanged(_ event: VideoDownloadQualityChangedEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }

        // no quality change if quality didn't change
        let videoBitrateDidChange = didVideoBitrateChange(old: event.videoQualityOld, new: event.videoQualityNew)
        guard videoBitrateDidChange else {
            return
        }

        // if nil we assume that previous quality is videoQualityOld
        if currentVideoQuality == nil {
            currentVideoQuality = event.videoQualityOld
        }

        stateMachine.videoQualityChange(time: currentTime) { [weak self] in
            self?.currentVideoQuality = event.videoQualityNew
        }
    }

    // No check if audioBitrate changes because no data available
    func onAudioChanged(_ event: AudioChangedEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }

        stateMachine.audioQualityChange(time: currentTime)
    }

    func onSeeked(_ event: SeekedEvent, player: Player) {
        guard isEventRelevantForCurrentSource else {
            return
        }
        logger.d("onSeeked: currentTime: \(player.currentTime), isPlaying: \(player.isPlaying), isPaused: \(player.isPaused)")
        isSeeking = false
        if !isStalling {
            transitionToPausedOrBufferingOrPlaying()
        }
    }

    func onPlaybackFinished(_ event: PlaybackFinishedEvent, player: Player) {
        let duration = player.durationMillis
        stateMachine.pause(time: duration)
        stateMachine.reset()
    }

    func onPlayerError(_ event: PlayerErrorEvent, player: Player) {
        let errorData = ErrorData(code: Int(event.code.rawValue), message: event.message, data: nil)
        onErrorEvent(errorData)
    }

    func transitionToPausedOrBufferingOrPlaying() {
        if !stateMachine.didStartPlayingVideo {
            return
        }

        if isStalling {
            // Player reports isPlaying=true although onStallEnded has not been called yet -- still stalling
            stateMachine.transitionState(destinationState: .buffering, time: player.currentTimeMillis)
        } else if player.isPaused {
            stateMachine.pause(time: currentTime)
        } else {
            stateMachine.playing(time: currentTime)
        }
    }

    func onSourceMetadataChanged(_ event: SourceMetadataChangedEvent, player: Player) {
        logger.d("onSourceMetadataChanged \(event.name)")
    }

    func onPlayerActive(_ event: PlayerActiveEvent, player: Player) {
        didEmitSourceLoadAfterPlayerActive = false
    }

    func onSourceLoad(_ event: SourceLoadEvent, player: Player) {
        if !didEmitSourceLoadAfterPlayerActive {
            didEmitSourceLoadAfterPlayerActive = true
            overrideCurrentSource = event.source
        }
        if player.config.playbackConfig.isAutoplayEnabled && !stateMachine.didAttemptPlayingVideo {
            stateMachine.play(time: currentTime)
        }
        logger.d("onSourceLoad: \(event.source.sourceConfig.url)")
    }

    func onSourceLoaded(_ event: SourceLoadedEvent, player: Player) {
        logger.d("onSourceLoaded: \(event.source.sourceConfig.url)")
    }

    func onSourceUnload(_ event: SourceUnloadEvent, player: Player) {
        logger.d("onSourceUnload")
        if !stateMachine.didStartPlayingVideo && stateMachine.didAttemptPlayingVideo {
            stateMachine.onPlayAttemptFailed(withReason: VideoStartFailedReason.pageClosed)
        }
    }

    func onSourceUnloaded(_ event: SourceUnloadedEvent, player: Player) {
        stateMachine.reset()
    }

    func onPlaylistTransition(_ event: PlaylistTransitionEvent, player: Player) {
        logger.d("""
        onPlaylistTransition \(player.currentTime), isPlaying: \(player.isPlaying),
        isPaused: \(player.isPaused), from: \(event.from.sourceConfig.url), to: \(event.to.sourceConfig.url)
        """)
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
        stateMachine.transitionState(destinationState: .subtitlechange, time: currentTime)
        transitionToPausedOrBufferingOrPlaying()
    }
}

extension BitmovinPlayerAdapter: SourceListener {
    func onSourceError(_ event: SourceErrorEvent, player: Player) {
        let errorData = ErrorData(code: Int(event.code.rawValue), message: event.message, data: nil)
        onErrorEvent(errorData)
    }
}
