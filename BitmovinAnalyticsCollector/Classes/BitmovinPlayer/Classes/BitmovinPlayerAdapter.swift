import Foundation
import BitmovinPlayer

class BitmovinPlayerAdapter: NSObject, PlayerAdapter {
    private let stateMachine: StateMachine
    private let config: BitmovinAnalyticsConfig
    private var player: BitmovinPlayer
    private var errorCode: Int?
    private var errorDescription: String?

    init(player: BitmovinPlayer, config: BitmovinAnalyticsConfig, stateMachine: StateMachine) {
        self.player = player
        self.stateMachine = stateMachine
        self.config = config
        super.init()
        startMonitoring()
    }

    func createEventData() -> EventData {
        let eventData: EventData = EventData(config: config, impressionId: stateMachine.impressionId)
        decorateEventData(eventData: eventData)
        return eventData
    }

    deinit {
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
        eventData.isLive = player.isLive

        //version
        if let sdkVersion = Bundle(for: BitmovinPlayer.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            eventData.version = sdkVersion
        }

        // streamForamt, hlsUrl
        eventData.streamForamt = "hls"

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

    }

    func startMonitoring() {
        player.add(listener: self)
    }

    func stopMonitoring() {
        player.remove(listener: self)
    }
}

extension BitmovinPlayerAdapter: PlayerListener {
    func onPlay(_ event: PlayEvent) {
        stateMachine.transitionState(destinationState: .playing, time: Util.doubleToCMTime(double: player.currentTime))
    }

    func onPaused(_ event: PausedEvent) {
        stateMachine.transitionState(destinationState: .paused, time: Util.doubleToCMTime(double: player.currentTime))
    }

    func onReady(_ event: ReadyEvent) {
        transitionToPausedOrPlaying()
    }

    func onStallStarted(_ event: StallStartedEvent) {
        stateMachine.transitionState(destinationState: .buffering, time: Util.doubleToCMTime(double: player.currentTime))
    }

    func onStallEnded(_ event: StallEndedEvent) {
        transitionToPausedOrPlaying()
    }

    func onSeek(_ event: SeekEvent) {
        stateMachine.transitionState(destinationState: .seeking, time: Util.doubleToCMTime(double: player.currentTime))
    }

    func onVideoDownloadQualityChanged(_ event: VideoDownloadQualityChangedEvent) {
        stateMachine.transitionState(destinationState: .qualitychange, time: Util.doubleToCMTime(double: player.currentTime))
        transitionToPausedOrPlaying()
    }

    func onSeeked(_ event: SeekedEvent) {
        transitionToPausedOrPlaying()
    }

    func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
                    stateMachine.transitionState(destinationState: .paused, time: Util.doubleToCMTime(double: player.currentTime))
        stateMachine.disableHeartbeat()
    }

    func onError(_ event: ErrorEvent) {
        errorCode = Int(event.code)
        errorDescription = event.description
        stateMachine.transitionState(destinationState: .error, time: Util.doubleToCMTime(double: player.currentTime))
    }

    func transitionToPausedOrPlaying() {
        if player.isPaused {
            stateMachine.transitionState(destinationState: .paused, time: Util.doubleToCMTime(double: player.currentTime))
        } else {
            stateMachine.transitionState(destinationState: .playing, time: Util.doubleToCMTime(double: player.currentTime))
        }
    }
}
