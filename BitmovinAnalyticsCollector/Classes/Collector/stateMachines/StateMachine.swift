import AVFoundation
import Foundation

public class StateMachine {
    private static var kVideoStartFailedTimeoutSeconds: TimeInterval = 60
    private static var kvideoStartFailedTimerId: String = "com.bitmovin.analytics.core.statemachine.startupFailedTimer"
    
    public private(set) var state: PlayerState
    private var config: BitmovinAnalyticsConfig
    private(set) var impressionId: String
    weak var delegate: StateMachineDelegate?
    
    //tracked player times
    private(set) var stateEnterTimestamp: Int64 = 0
    var startupTime: Int64 = 0
    private(set) var videoTimeStart: CMTime?
    internal var videoTimeEnd: CMTime?
    
    // heartbeat
    weak private var heartbeatTimer: Timer?
    private let heartbeatInterval: Int = 59700
    
    //play attempt
    public private(set) var didAttemptPlayingVideo: Bool = false
    public private(set) var didStartPlayingVideo: Bool = false
    private var videoStartFailedWorkItem: DispatchWorkItem?
    private(set) var videoStartFailed: Bool = false
    private(set) var videoStartFailedReason: String?
    
    // features objects
    public var qualityChangeCounter: QualityChangeCounter
    public var rebufferingHeartbeatService: RebufferingHeartbeatService
    
    // error tracking
    private var errorData: ErrorData? = nil

    init(config: BitmovinAnalyticsConfig) {
        self.config = config
        state = .ready
        impressionId = NSUUID().uuidString
        qualityChangeCounter = QualityChangeCounter()
        self.rebufferingHeartbeatService = RebufferingHeartbeatService()
        print("Generated Bitmovin Analytics impression ID: " + impressionId.lowercased())
        
        // needs to happen after init of properties
        self.rebufferingHeartbeatService.initialise(stateMachine: self)
    }

    deinit {
        disableHeartbeat()
        self.rebufferingHeartbeatService.disableRebufferHeartbeat()
    }

    private func resetSourceState() {
        impressionId = NSUUID().uuidString
        didAttemptPlayingVideo = false
        didStartPlayingVideo = false
        startupTime = 0
        disableHeartbeat()
        rebufferingHeartbeatService.disableRebufferHeartbeat()
        resetVideoStartFailed()
        qualityChangeCounter.resetInterval()
        delegate?.stateMachineResetSourceState()
        print("Generated Bitmovin Analytics impression ID: " +  impressionId.lowercased())
    }
    
    public func reset(){
        state = .ready
        resetSourceState()
    }

    public func transitionState(destinationState: PlayerState, time: CMTime?) {
        transitionState(destinationState: destinationState, playerTime: time, enterTimestamp: Date().timeIntervalSince1970Millis)
    }
    
    private func transitionState(destinationState: PlayerState, playerTime: CMTime?, enterTimestamp overrideEnterTimestamp: Int64?) {
        let performTransition = checkUnallowedTransitions(destinationState: destinationState)

        if performTransition {
            print("[StateMachine] Transitioning from state \(state) to \(destinationState)")
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
    
    public func play(time: CMTime?) {
        if(didStartPlayingVideo) {
            return
        }
        
        didAttemptPlayingVideo = true
        transitionState(destinationState: .startup, time: time)
    }
    
    public func pause(time: CMTime?) {
        let destinationState = didStartPlayingVideo ? PlayerState.paused : PlayerState.ready
        transitionState(destinationState: destinationState, time: time)
    }
    
    public func playing(time: CMTime?) {
        transitionState(destinationState: .playing, time: time)
    }
    
    public func seek(time: CMTime?, overrideEnterTimestamp: Int64? = nil) {
        transitionState(destinationState: .seeking, playerTime: time, enterTimestamp: overrideEnterTimestamp)
    }
    
    public func videoQualityChange(time: CMTime?, setQualityFunction: @escaping () -> Void) {
        qualityChange(.qualitychange, time: time, setQualityFunction: setQualityFunction)
    }
    
    public func audioQualityChange(time: CMTime?) {
        qualityChange(.audiochange, time: time, setQualityFunction: nil)
    }
    
    private func qualityChange(_ qualityState: PlayerState, time: CMTime?, setQualityFunction: (() -> Void)?) {
        if !qualityChangeCounter.isQualityChangeEnabled() {
            setQualityFunction?()
            return
        }
        
        let previousState = state
        transitionState(destinationState: qualityState, time: time)
        setQualityFunction?()
        transitionState(destinationState: previousState, time: time)
    }
    
    public func error(withError error: ErrorData, time: CMTime?) {
        self.errorData = error
        transitionState(destinationState: .error, time: time)
    }
    
    public func sourceChange(_ previousVideoDuration: CMTime?, _ nextVideotimeStart: CMTime?, _ shouldStartup: Bool) {
        transitionState(destinationState: .sourceChanged, time: previousVideoDuration)
        resetSourceState()
        
        if (shouldStartup) {
            transitionState(destinationState: .startup, time: nextVideotimeStart)
        }
    }
    
    public func rebufferTimeoutReached(time: CMTime?) {
        self.errorData = ErrorData.ANALYTICS_BUFFERING_TIMEOUT_REACHED
        transitionState(destinationState: .error, time: time)
        self.delegate?.stateMachineStopsCollecting()
    }
    
    public func setDidStartPlayingVideo() {
        didStartPlayingVideo = true
    }
    
    public func startVideoStartFailedTimer() {
        // The second test makes sure to not start the timer during an ad or if the player is paused on resuming from background
        if(didStartPlayingVideo || state != .startup) {
            return
        }
        clearVideoStartFailedTimer()
        
        videoStartFailedWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.errorData = ErrorData.ANALYTICS_VIDEOSTART_TIMEOUT_REACHED
            self.onPlayAttemptFailed(withReason: VideoStartFailedReason.timeout)
        }
        DispatchQueue.init(label: StateMachine.kvideoStartFailedTimerId).asyncAfter(deadline: .now() + StateMachine.kVideoStartFailedTimeoutSeconds, execute: videoStartFailedWorkItem!)
    }
    
    public func clearVideoStartFailedTimer() {
        if (videoStartFailedWorkItem == nil) {
            return
        }
        videoStartFailedWorkItem!.cancel()
        videoStartFailedWorkItem = nil
    }
    
    public func setVideoStartFailed(withReason reason: String) {
        clearVideoStartFailedTimer()
        videoStartFailed = true
        videoStartFailedReason = reason
    }
    
    public func resetVideoStartFailed() {
        videoStartFailed = false
        videoStartFailedReason = nil
    }
    
    public func onPlayAttemptFailed(withReason reason: String = VideoStartFailedReason.unknown) {
        setVideoStartFailed(withReason: reason)
        transitionState(destinationState: .playAttemptFailed, time: nil)
        self.delegate?.stateMachineStopsCollecting()
    }
    
    public func onPlayAttemptFailed(withError error: ErrorData) {
        setVideoStartFailed(withReason: VideoStartFailedReason.playerError)
        self.errorData = error
        transitionState(destinationState: .playAttemptFailed, time: nil)
        self.delegate?.stateMachineStopsCollecting()
    }
    
    private func checkUnallowedTransitions(destinationState: PlayerState) -> Bool{
        if state == destinationState {
            return false
        } else if state == .buffering && (destinationState == .qualitychange || destinationState == .audiochange) {
            return false
        } else if state == .seeking && (destinationState == .qualitychange || destinationState == .buffering || destinationState == .audiochange) {
            return false
        } else if state == .ready && (destinationState != .error && destinationState != .playAttemptFailed && destinationState != .startup && destinationState != .ad) {
            return false
        } else if state == .startup && (destinationState != .error && destinationState != .playAttemptFailed && destinationState != .ready && destinationState != .playing && destinationState != .ad) {
            return false
        } else if state == .ad && (destinationState != .error && destinationState != .adFinished) {
            return false
        } else if state == .playAttemptFailed {
            return false
        // transition from paused to seeking is allowed because if seeking is triggered with UI
        // first pause is triggered and then seeking
        } else if state == .paused && (destinationState == .qualitychange || destinationState == .buffering || destinationState == .audiochange) {
            return false
        }
        
        return true
    }

    func enableHeartbeat() {
        let interval = Double(heartbeatInterval) / 1_000.0
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(StateMachine.onHeartbeat), userInfo: nil, repeats: true)
    }

    func disableHeartbeat() {
        heartbeatTimer?.invalidate()
    }
    
    @objc func onHeartbeat() {
        videoTimeEnd = delegate?.currentTime
        let timestamp = Date().timeIntervalSince1970Millis
        delegate?.stateMachine(self, didHeartbeatWithDuration: timestamp - stateEnterTimestamp)
        videoTimeStart = videoTimeEnd
        stateEnterTimestamp = timestamp
    }
    
    public func getErrorData() -> ErrorData? {
        self.errorData
    }
    
    public func setErrorData(error: ErrorData?) {
        self.errorData = error
    }
    
    internal func changeCustomData(customData: CustomData, time: CMTime?, customDataConfig: CustomDataConfig){
        let originalState = state
        let shouldTransition = (originalState == PlayerState.paused || originalState == PlayerState.playing)
        if shouldTransition {
            transitionState(destinationState: PlayerState.customdatachange,time: time)
        }
        customDataConfig.setCustomData(customData: customData)
        if shouldTransition {
            transitionState(destinationState: originalState, time: time)
        }
    }
}
