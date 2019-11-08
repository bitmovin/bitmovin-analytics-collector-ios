import Foundation
import BitmovinPlayer

class BitmovinPlayerAdapter: NSObject, PlayerAdapter {
    private let stateMachine: StateMachine
    private let config: BitmovinAnalyticsConfig
    private var player: BitmovinPlayer
    private var errorCode: Int?
    private var errorDescription: String?
    private var isPlayerReady: Bool

    init(player: BitmovinPlayer, config: BitmovinAnalyticsConfig, stateMachine: StateMachine) {
        self.player = player
        self.stateMachine = stateMachine
        self.config = config
        self.isPlayerReady = false
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
        if  self.isPlayerReady {
            eventData.isLive = player.isLive
        }
        else {
            eventData.isLive = self.config.isLive
        }

        //version
        if let sdkVersion = Bundle(for: BitmovinPlayer.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
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
}

extension BitmovinPlayerAdapter: PlayerListener {
    func onPlay(_ event: PlayEvent) {
        stateMachine.transitionState(destinationState: .playing, time: Util.timeIntervalToCMTime(_: player.currentTime))
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
                    stateMachine.transitionState(destinationState: .paused, time: Util.timeIntervalToCMTime(_: player.currentTime))
        stateMachine.disableHeartbeat()
    }

    func onError(_ event: ErrorEvent) {
        errorCode = Int(event.code)
        errorDescription = event.description
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
