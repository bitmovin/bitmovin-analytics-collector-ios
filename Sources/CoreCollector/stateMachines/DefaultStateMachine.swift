import AVFoundation
import Foundation

class DefaultStateMachine: StateMachine, RebufferHeartbeatListener, PlayingHeartbeatListener, RebufferTimeoutListener {
    private let logger = _AnalyticsLogger(className: "DefaultStateMachine")
    private(set) var state: PlayerState
    private(set) var impressionId: String
    weak var listener: StateMachineListener?

    // tracked player times
    private(set) var stateEnterTimestamp: Int64 = 0
    var startupTime: Int64 = 0
    private(set) var videoTimeStart: CMTime?
    var videoTimeEnd: CMTime?

    // heartbeat
    private weak var heartbeatTimer: Timer?
    private let heartbeatInterval: Int = 59_700

    // play attempt
    private(set) var didAttemptPlayingVideo = false
    private(set) var didStartPlayingVideo = false

    // features objects
    var qualityChangeCounter: QualityChangeCounter
    var rebufferingHeartbeatService: RebufferingHeartbeatService
    var videoStartFailureService: VideoStartFailureService
    var playingHeartbeatService: PlayingHeartbeatService

    private let playerContext: PlayerContext

    // error tracking
    private var errorData: ErrorData?

    init(playerContext: PlayerContext) {
        state = .ready
        impressionId = NSUUID().uuidString
        qualityChangeCounter = QualityChangeCounter()
        let rebufferingTimeoutHandler = RebufferingTimeoutHandler()
        rebufferingHeartbeatService = RebufferingHeartbeatService(timeoutHandler: rebufferingTimeoutHandler)
        playingHeartbeatService = PlayingHeartbeatService()
        videoStartFailureService = VideoStartFailureService()
        self.playerContext = playerContext
        logger.i("Generated Bitmovin Analytics impression ID: \(impressionId.lowercased())")

        // needs to happen after init of properties
        rebufferingTimeoutHandler.listeners = self
        videoStartFailureService.initialise(stateMachine: self)
        rebufferingHeartbeatService.listener = self
        playingHeartbeatService.listener = self
    }

    deinit {
        self.playingHeartbeatService.disableHeartbeat()
        self.rebufferingHeartbeatService.disableHeartbeat()
    }

    private func resetSourceState() {
        impressionId = NSUUID().uuidString
        didAttemptPlayingVideo = false
        didStartPlayingVideo = false
        startupTime = 0
        self.playingHeartbeatService.disableHeartbeat()
        rebufferingHeartbeatService.disableHeartbeat()
        videoStartFailureService.reset()
        qualityChangeCounter.resetInterval()
        listener?.stateMachineResetSourceState()
        logger.i("Generated Bitmovin Analytics impression ID: \( impressionId.lowercased())")
    }

    func reset() {
        state = .ready
        resetSourceState()
    }

    func transitionState(destinationState: PlayerState, time: CMTime?) {
        transitionState(
            destinationState: destinationState,
            playerTime: time,
            enterTimestamp: Date().timeIntervalSince1970Millis
        )
    }

    private func transitionState(
        destinationState: PlayerState,
        playerTime: CMTime?,
        enterTimestamp overrideEnterTimestamp: Int64?
    ) {
        let performTransition = checkUnallowedTransitions(destinationState: destinationState)

        if performTransition {
            logger.d("Transitioning from state \(state) to \(destinationState)")
            let usedEnterTimestamp = overrideEnterTimestamp ?? Date().timeIntervalSince1970Millis
            videoTimeEnd = playerTime

            // Get the time spend in the current state
            let duration = usedEnterTimestamp - stateEnterTimestamp
            state.onExit(stateMachine: self, duration: duration, destinationState: destinationState)

            state = destinationState
            stateEnterTimestamp = usedEnterTimestamp
            videoTimeStart = videoTimeEnd
            state.onEntry(stateMachine: self)
        }
    }

    func play(time: CMTime?) {
        if didStartPlayingVideo {
            return
        }

        didAttemptPlayingVideo = true
        transitionState(destinationState: .startup, time: time)
    }

    func pause(time: CMTime?) {
        let destinationState = didStartPlayingVideo ? PlayerState.paused : PlayerState.ready
        transitionState(destinationState: destinationState, time: time)
    }

    func playing(time: CMTime?) {
        transitionState(destinationState: .playing, time: time)
    }

    func seek(time: CMTime?) {
        transitionState(destinationState: .seeking, time: time)
    }

    func seek(time: CMTime?, overrideEnterTimestamp: Int64? = nil) {
        transitionState(destinationState: .seeking, playerTime: time, enterTimestamp: overrideEnterTimestamp)
    }

    func videoQualityChange(time: CMTime?, setQualityFunction: @escaping () -> Void) {
        qualityChange(.qualitychange, time: time, setQualityFunction: setQualityFunction)
    }

    func audioQualityChange(time: CMTime?) {
        qualityChange(.audiochange, time: time, setQualityFunction: nil)
    }

    private func qualityChange(_ qualityState: PlayerState, time: CMTime?, setQualityFunction: (() -> Void)?) {
        if !qualityChangeCounter.isQualityChangeEnabled {
            setQualityFunction?()
            return
        }

        let previousState = state
        transitionState(destinationState: qualityState, time: time)
        setQualityFunction?()
        transitionState(destinationState: previousState, time: time)
    }

    func error(withError error: ErrorData, time: CMTime?) {
        self.errorData = error
        transitionState(destinationState: .error, time: time)
        self.errorData = nil
    }

    func sourceChange(_ previousVideoDuration: CMTime?, _ nextVideotimeStart: CMTime?, _ shouldStartup: Bool) {
        transitionState(destinationState: .sourceChanged, time: previousVideoDuration)
        resetSourceState()

        if shouldStartup {
            transitionState(destinationState: .startup, time: nextVideotimeStart)
        }
    }

    func ad(time: CMTime?) {
        transitionState(destinationState: .ad, time: time)
    }
    func adFinished() {
        transitionState(destinationState: .adFinished, time: videoTimeEnd)
    }

    func setDidStartPlayingVideo() {
        didStartPlayingVideo = true
    }

    func onPlayAttemptFailed(withReason reason: String) {
        videoStartFailureService.setVideoStartFailed(withReason: reason)
        transitionState(destinationState: .playAttemptFailed, time: nil)
        self.listener?.stateMachineStopsCollecting()
    }

    func onPlayAttemptFailed(
        withReason reason: String = VideoStartFailedReason.unknown,
        withError error: ErrorData? = nil
    ) {
        self.errorData = error
        onPlayAttemptFailed(withReason: reason)
        self.errorData = nil
    }

    private func checkUnallowedTransitions(destinationState: PlayerState) -> Bool {
        if state == destinationState {
            return false
        } else if state == .buffering && (destinationState == .qualitychange || destinationState == .audiochange) {
            return false
        } else if state == .seeking &&
                    (destinationState == .qualitychange || destinationState == .buffering || destinationState == .audiochange) {
            return false
        } else if state == .ready &&
                    (destinationState != .error && destinationState != .playAttemptFailed && destinationState != .startup && destinationState != .ad) {
            return false
        } else if state == .startup &&
                    (destinationState != .error && destinationState != .playAttemptFailed && destinationState != .ready && destinationState != .playing && destinationState != .ad) {
            return false
        } else if state == .ad && (destinationState != .error && destinationState != .adFinished) {
            return false
        } else if state == .playAttemptFailed {
            return false
        // transition from paused to seeking is allowed because if seeking is triggered with UI
        // first pause is triggered and then seeking
        } else if state == .paused &&
                    (destinationState == .qualitychange || destinationState == .buffering || destinationState == .audiochange) {
            return false
        }

        return true
    }

    func onRebufferTimeout() {
        error(withError: ErrorData.BUFFERING_TIMEOUT_REACHED, time: listener?.currentTime)
        listener?.stateMachineStopsCollecting()
    }

    func onRebufferHeartbeat() {
        onHeartbeat()
    }

    func onPlayingHeartbeat() -> Bool {
        if playerContext.isPlaying {
            onHeartbeat()
            return true
        } else {
            pause(time: playerContext.position)
            return false
        }
    }

    private func onHeartbeat() {
        videoTimeEnd = listener?.currentTime
        let timestamp = Date().timeIntervalSince1970Millis
        let duration = timestamp - stateEnterTimestamp
        listener?.onHeartbeat(withDuration: duration, state: state)
        videoTimeStart = videoTimeEnd
        stateEnterTimestamp = timestamp
    }

    func getErrorData() -> ErrorData? {
        self.errorData
    }

    func setErrorData(error: ErrorData) {
        self.errorData = error
    }

    func changeCustomData(customData: CustomData, time: CMTime?, customDataConfig: CustomDataConfig) {
        let originalState = state
        let shouldTransition = (originalState == PlayerState.paused || originalState == PlayerState.playing)
        if shouldTransition {
            transitionState(destinationState: PlayerState.customdatachange, time: time)
        }
        customDataConfig.setCustomData(customData: customData)
        if shouldTransition {
            transitionState(destinationState: originalState, time: time)
        }
    }
}
