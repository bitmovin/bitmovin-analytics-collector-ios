import AVFoundation
import Foundation

public class StateMachine {
    private(set) var state: PlayerState
    private var config: BitmovinAnalyticsConfig
    private var initialTimestamp: Int64
    private(set) var enterTimestamp: Int64?
    var potentialSeekStart: Int64 = 0
    var potentialSeekVideoTimeStart: CMTime?
    var firstReadyTimestamp: Int64?
    private(set) var videoTimeStart: CMTime?
    private(set) var videoTimeEnd: CMTime?
    private(set) var impressionId: String
    weak var delegate: StateMachineDelegate?
    weak private var heartbeatTimer: Timer?
    let rebufferHeartbeatQueue = DispatchQueue.init(label: "com.bitmovin.analytics.core.statemachine")
    private var rebufferHeartbeatTimer: DispatchWorkItem?
    private var currentRebufferIntervalIndex: Int = 0
    private let rebufferHeartbeatInterval: [Int64] = [3000, 5000, 10000, 59700]

    var startupTime: Int64 {
        guard let firstReadyTimestamp = firstReadyTimestamp else {
            return 0
        }
        return firstReadyTimestamp - initialTimestamp
    }

    init(config: BitmovinAnalyticsConfig) {
        self.config = config
        state = .setup
        initialTimestamp = Date().timeIntervalSince1970Millis
        impressionId = NSUUID().uuidString
        print("Generated Bitmovin Analytics impression ID: " + impressionId.lowercased())
    }

    deinit {
        disableHeartbeat()
        disableRebufferHeartbeat()
    }

    public func reset() {
        impressionId = NSUUID().uuidString
        initialTimestamp = Date().timeIntervalSince1970Millis
        firstReadyTimestamp = nil
        disableHeartbeat()
        disableRebufferHeartbeat()
        state = .setup
        print("Generated Bitmovin Analytics impression ID: " +  impressionId.lowercased())
    }

    public func transitionState(destinationState: PlayerState, time: CMTime?, data: [AnyHashable: Any]? = nil) {
        let performTransition = checkUnallowedTransitions(destinationState: destinationState)
        
        if performTransition {
            let timestamp = Date().timeIntervalSince1970Millis
            let previousState = state
            videoTimeEnd = time
            state.onExit(stateMachine: self, timestamp: timestamp, destinationState: destinationState)
            state = destinationState
            enterTimestamp = timestamp
            videoTimeStart = videoTimeEnd
            state.onEntry(stateMachine: self, timestamp: timestamp, previousState: previousState, data: data)
        }
    }
    
    private func checkUnallowedTransitions(destinationState: PlayerState) -> Bool{
        var allowed = true
        if state == destinationState {
            allowed = false
        } else if state == .buffering && destinationState == .qualitychange {
            allowed = false
        } else if state == .seeking && destinationState == .qualitychange {
            allowed = false
        } else if state == .seeking && destinationState == .buffering {
            allowed = false
        }
        
        return allowed
    }

    public func confirmSeek() {
        enterTimestamp = potentialSeekStart
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
    
    func enableRebufferHeartbeat() {
        self.rebufferHeartbeatTimer = DispatchWorkItem {
            guard self.rebufferHeartbeatTimer != nil else {
                return
            }
            
            self.onHeartbeat()
            self.currentRebufferIntervalIndex = min(self.currentRebufferIntervalIndex + 1, self.rebufferHeartbeatInterval.count - 1)
            self.rebufferHeartbeatQueue.asyncAfter(deadline: self.getRebufferDeadline(), execute: self.rebufferHeartbeatTimer!)
        }
        self.rebufferHeartbeatQueue.asyncAfter(deadline: getRebufferDeadline(), execute: self.rebufferHeartbeatTimer!)
    }

    func disableRebufferHeartbeat() {
        self.rebufferHeartbeatTimer?.cancel()
        self.rebufferHeartbeatTimer = nil
        self.currentRebufferIntervalIndex = 0
    }
    
    private func getRebufferDeadline() -> DispatchTime {
        let interval = Double(rebufferHeartbeatInterval[currentRebufferIntervalIndex]) / 1_000.0
        return DispatchTime.now() + interval
    }

    @objc func onHeartbeat() {
        guard let enterTime = enterTimestamp else {
            return
        }
        videoTimeEnd = delegate?.currentTime
        let timestamp = Date().timeIntervalSince1970Millis
        delegate?.stateMachine(self, didHeartbeatWithDuration: timestamp - enterTime)
        videoTimeStart = videoTimeEnd
        enterTimestamp = timestamp
    }
}
