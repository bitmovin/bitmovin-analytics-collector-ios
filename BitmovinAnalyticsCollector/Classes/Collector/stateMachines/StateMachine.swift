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
    public var potentialSeekStart: Int64 = 0
    public var potentialSeekVideoTimeStart: CMTime?
    var startupTime: Int64 = 0
    private(set) var videoTimeStart: CMTime?
    internal var videoTimeEnd: CMTime?
    
    // heartbeat
    weak private var heartbeatTimer: Timer?
    let rebufferHeartbeatQueue = DispatchQueue.init(label: "com.bitmovin.analytics.core.statemachine.heartBeatQueue")
    private var rebufferHeartbeatTimer: DispatchWorkItem?
    private var currentRebufferIntervalIndex: Int = 0
    private let rebufferHeartbeatInterval: [Int64] = [3000, 5000, 10000, 59700]
    
    //play attempt
    public private(set) var didAttemptPlayingVideo: Bool = false
    public private(set) var didStartPlayingVideo: Bool = false
    private var videoStartFailedWorkItem: DispatchWorkItem?
    private(set) var videoStartFailed: Bool = false
    private(set) var videoStartFailedReason: String?
    
    // features objects
    public var qualityChangeCounter: QualityChangeCounter
    public var rebufferingTimeoutHandler: RebufferingTimeoutHandler
    
    // error tracking
    private var errorData: ErrorData? = nil

    init(config: BitmovinAnalyticsConfig) {
        self.config = config
        state = .ready
        impressionId = NSUUID().uuidString
        qualityChangeCounter = QualityChangeCounter()
        self.rebufferingTimeoutHandler = RebufferingTimeoutHandler()
        print("Generated Bitmovin Analytics impression ID: " + impressionId.lowercased())
        
        // needs to happen after init of properties
        self.rebufferingTimeoutHandler.initialise(stateMachine: self)
    }

    deinit {
        disableHeartbeat()
        disableRebufferHeartbeat()
    }

    private func resetSourceState() {
        impressionId = NSUUID().uuidString
        didAttemptPlayingVideo = false
        didStartPlayingVideo = false
        startupTime = 0
        disableHeartbeat()
        disableRebufferHeartbeat()
        resetVideoStartFailed()
        qualityChangeCounter.resetInterval()
        rebufferingTimeoutHandler.resetInterval()
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
    
    public func videoQualityChange(time: CMTime?) {
        if !qualityChangeCounter.isQualityChangeEnabled() {
            return
        }
        transitionState(destinationState: .qualitychange, time: time)
    }
    
    public func audioQualityChange(time: CMTime?) {
        if !qualityChangeCounter.isQualityChangeEnabled() {
            return
        }
        transitionState(destinationState: .audiochange, time: time)
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
        } else if state == .buffering && destinationState == .qualitychange {
            return false
        } else if state == .seeking && destinationState == .qualitychange {
            return false
        } else if state == .seeking && destinationState == .buffering {
            return false
        } else if state == .ready && (destinationState != .error && destinationState != .playAttemptFailed && destinationState != .startup && destinationState != .ad) {
            return false
        } else if state == .startup && (destinationState != .error && destinationState != .playAttemptFailed && destinationState != .ready && destinationState != .playing && destinationState != .ad) {
            return false
        } else if state == .ad && (destinationState != .error && destinationState != .adFinished) {
            return false
        } else if state == .playAttemptFailed {
            return false
        } else if state == .paused && (destinationState == .qualitychange || destinationState == .seeking || destinationState == .buffering) {
            return false
        }
        
        return true
    }

    public func confirmSeek() {
        stateEnterTimestamp = potentialSeekStart
        videoTimeStart = potentialSeekVideoTimeStart
        potentialSeekStart = 0
        potentialSeekVideoTimeStart = CMTime.zero
    }

    func enableHeartbeat() {
        let interval = Double(config.heartbeatInterval) / 1_000.0
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(StateMachine.onHeartbeat), userInfo: nil, repeats: true)
    }

    func disableHeartbeat() {
        heartbeatTimer?.invalidate()
    }
    
    func scheduleRebufferHeartbeat() {
        self.rebufferHeartbeatTimer = DispatchWorkItem { [weak self] in
            guard let self = self,
                self.rebufferHeartbeatTimer != nil else {
                return
            }
            self.onHeartbeat()
            self.currentRebufferIntervalIndex = min(self.currentRebufferIntervalIndex + 1, self.rebufferHeartbeatInterval.count - 1)
            self.scheduleRebufferHeartbeat()
        }
        self.rebufferHeartbeatQueue.asyncAfter(deadline: getRebufferDeadline(), execute: self.rebufferHeartbeatTimer!)
    }

    func disableRebufferHeartbeat() {
        self.rebufferHeartbeatQueue.sync {
            self.rebufferHeartbeatTimer?.cancel()
            self.rebufferHeartbeatTimer = nil
            self.currentRebufferIntervalIndex = 0
        }
    }
    
    private func getRebufferDeadline() -> DispatchTime {
        let interval = Double(rebufferHeartbeatInterval[currentRebufferIntervalIndex]) / 1_000.0
        return DispatchTime.now() + interval
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
