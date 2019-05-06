import AVFoundation
import Foundation
/**
 * An iOS analytics plugin that sends video playback analytics to Bitmovin Analytics servers. Currently
 * supports analytics on AVPlayer video players
 */
public class BitmovinAnalyticsInternal {
    public static let ErrorMessageKey = "errorMessage"
    public static let ErrorCodeKey = "errorCode"
    
    static let msInSec = 1000.0
    internal var config: BitmovinAnalyticsConfig
    internal var stateMachine: StateMachine
    private var adapter: PlayerAdapter?
    private var eventDataDispatcher: EventDataDispatcher

    internal init(config: BitmovinAnalyticsConfig) {
        self.config = config
        stateMachine = StateMachine(config: self.config)
        eventDataDispatcher = SimpleEventDataDispatcher(config: config)
        NotificationCenter.default.addObserver(self, selector: #selector(licenseFailed(notification:)), name: .licenseFailed, object: eventDataDispatcher)
    }

    /**
     * Detach the current player that is being used with Bitmovin Analytics.
     */
    public func detachPlayer() {
        eventDataDispatcher.disable()
        stateMachine.reset()
        adapter = nil
    }
    
    internal func attach(adapter: PlayerAdapter) {
        stateMachine.delegate = self
        eventDataDispatcher.enable()
        self.adapter = adapter
    }

    @objc private func licenseFailed(notification _: Notification) {
        detachPlayer()
    }

    private func sendEventData(eventData: EventData?) {
        guard let data = eventData else {
            return
        }
        print("error message: ", eventData?.errorMessage, ", error code: ", eventData?.errorCode)
        eventDataDispatcher.add(eventData: data)
    }

    private func createEventData(duration: Int64) -> EventData? {
        guard let eventData = adapter?.createEventData() else {
            return nil
        }
        eventData.state = stateMachine.state.rawValue
        eventData.duration = duration

        if let timeStart = stateMachine.videoTimeStart {
            eventData.videoTimeStart = Int64(CMTimeGetSeconds(timeStart) * BitmovinAnalyticsInternal.msInSec)
        }
        if let timeEnd = stateMachine.videoTimeEnd {
            eventData.videoTimeEnd = Int64(CMTimeGetSeconds(timeEnd) * BitmovinAnalyticsInternal.msInSec)
        }
        return eventData
    }
}

extension BitmovinAnalyticsInternal: StateMachineDelegate {

    func stateMachineDidExitSetup(_ stateMachine: StateMachine) {
    }

    func stateMachine(_ stateMachine: StateMachine, didExitBufferingWithDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        sendEventData(eventData: eventData)
    }

    func stateMachineDidEnterError(_ stateMachine: StateMachine, data: [AnyHashable: Any]?) {
        let eventData = createEventData(duration: 0)
        if let errorCode = data?[BitmovinAnalyticsInternal.ErrorCodeKey] {
            eventData?.errorCode = errorCode as? Int
        }
        if let errorMessage = data?[BitmovinAnalyticsInternal.ErrorMessageKey] {
            eventData?.errorMessage = errorMessage as? String
        }
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didExitPlayingWithDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData?.played = duration
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didExitPauseWithDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData?.paused = duration
        sendEventData(eventData: eventData)
    }

    func stateMachineDidQualityChange(_ stateMachine: StateMachine) {
        let eventData = createEventData(duration: 0)
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didExitSeekingWithDuration duration: Int64, destinationPlayerState: PlayerState) {
        let eventData = createEventData(duration: duration)
        eventData?.seeked = duration
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didHeartbeatWithDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        switch stateMachine.state {
        case .playing:
            eventData?.played = duration
            break
        case .paused:
            eventData?.paused = duration
            break
        case .buffering:
            eventData?.buffered = duration
            break
        default:
            break
        }
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didStartupWithDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData?.videoStartupTime = duration
        // Hard coding 1 as the player startup time to workaround a Dashboard issue
        eventData?.playerStartupTime = 1
        eventData?.startupTime = duration+1
        eventData?.supportedVideoCodecs = Util.getSupportedVideoCodecs()

        eventData?.state = "startup"
        sendEventData(eventData: eventData)
    }
}
