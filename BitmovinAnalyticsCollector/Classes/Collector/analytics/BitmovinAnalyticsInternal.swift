import AVFoundation
import Foundation
/**
 * An iOS analytics plugin that sends video playback analytics to Bitmovin Analytics servers. Currently
 * supports analytics on AVPlayer video players
 */
public class BitmovinAnalyticsInternal: NSObject {
    public static let ErrorMessageKey = "errorMessage"
    public static let ErrorCodeKey = "errorCode"
    public static let ErrorDataKey = "errorData"

    static let msInSec = 1_000.0
    internal var config: BitmovinAnalyticsConfig
    internal var stateMachine: StateMachine
    internal var adapter: PlayerAdapter?
    private var eventDataDispatcher: EventDataDispatcher
    internal var adAnalytics: BitmovinAdAnalytics?
    internal var adAdapter: AdAdapter?
    internal var eventDataFactory: EventDataFactory
    private var isPlayerAttached = false
    internal var didSendDrmLoadTime = false

    internal init(config: BitmovinAnalyticsConfig) {
        self.config = config
        stateMachine = StateMachine(config: self.config)
        eventDataDispatcher = SimpleEventDataDispatcher(config: config)
        eventDataFactory = EventDataFactory(config)
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(licenseFailed(notification:)), name: .licenseFailed, object: eventDataDispatcher)
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationWillTerminate(notification:)),
            name: UIApplication.willTerminateNotification,
            object: nil)
        
        if (config.ads) {
            self.adAnalytics = BitmovinAdAnalytics(analytics: self);
        }
    }
    
    deinit {
        self.detachPlayer()
    }
    
    /**
     * Detach the current player that is being used with Bitmovin Analytics.
     */
    @objc public func detachPlayer() {
        guard isPlayerAttached else {
            return
        }
        isPlayerAttached = false
        detachAd();
        adapter?.destroy()
        eventDataDispatcher.resetSourceState()
        eventDataDispatcher.disable()
        stateMachine.reset()
        adapter = nil
    }

    internal func attach(adapter: PlayerAdapter) {
        if isPlayerAttached {
            detachPlayer()
        }
        isPlayerAttached = true
        stateMachine.delegate = self
        eventDataDispatcher.enable()
        self.adapter = adapter
        self.adapter!.initialize()
    }
    
    private func detachAd() {
        adAdapter?.releaseAdapter()
    }
    
    internal func attachAd(adAdapter: AdAdapter) {
        self.adAdapter = adAdapter;
    }
    
    @objc private func licenseFailed(notification _: Notification) {
        detachPlayer()
    }
    
    @objc private func applicationWillTerminate(notification _: Notification) {
        detachPlayer()
    }
    
    @objc public func getCustomData() -> CustomData {
        let sourceMetadata = adapter?.currentSourceMetadata
        return sourceMetadata?.getCustomData() ?? self.config.getCustomData()
    }
    
    @objc public func setCustomData(customData: CustomData) {
        guard self.adapter != nil else {
            return
        }
        let sourceMetadata = adapter?.currentSourceMetadata
        let customDataConfig: CustomDataConfig = sourceMetadata ?? self.config
        
        self.stateMachine.changeCustomData(customData: customData, time: self.currentTime, customDataConfig: customDataConfig)
    }
    
    @objc public func setCustomDataOnce(customData: CustomData) {
        guard self.adapter != nil else {
            return
        }
        
        let sourceMetadata = adapter?.currentSourceMetadata
        
        let customDataConfig: CustomDataConfig = sourceMetadata ?? self.config
        
        let currentCustomData = customDataConfig.getCustomData()
        
        customDataConfig.setCustomData(customData: customData)
        let eventData = createEventData(duration: 0)
        eventData.state = PlayerState.customdatachange.rawValue
        sendEventData(eventData: eventData)
        customDataConfig.setCustomData(customData: currentCustomData)
        
    }

    private func sendEventData(eventData: EventData?) {
        guard let data = eventData else {
            return
        }
        eventDataDispatcher.add(eventData: data)
    }
    
    internal func sendAdEventData(adEventData: AdEventData?) {
        guard let data = adEventData else {
            return
        }
        eventDataDispatcher.addAd(adEventData: data)
    }

    internal func createEventData(duration: Int64) -> EventData {
        
        var drmLoadTime: Int64? = nil
        if adapter?.drmDownloadTime != nil && !didSendDrmLoadTime {
            drmLoadTime = adapter?.drmDownloadTime
            didSendDrmLoadTime = true
        }
        
        let eventData = self.eventDataFactory.createEventData(
            self.stateMachine.state.rawValue,
            self.stateMachine.impressionId,
            self.stateMachine.videoTimeStart,
            self.stateMachine.videoTimeEnd,
            drmLoadTime,
            self.adapter?.currentSourceMetadata,
            self.stateMachine.videoStartFailed,
            self.stateMachine.videoStartFailedReason)
        self.adapter?.decorateEventData(eventData: eventData)
        eventData.duration = duration
        return eventData
    }
    
    internal func reset(){
        eventDataDispatcher.resetSourceState()
        didSendDrmLoadTime = false
    }
    
}

extension BitmovinAnalyticsInternal: StateMachineDelegate {

    func stateMachineDidExitSetup(_ stateMachine: StateMachine) {
    }

    func stateMachineEnterPlayAttemptFailed(stateMachine: StateMachine) {
        let eventData = createEventData(duration: 0)
        if let errorData = stateMachine.getErrorData() {
            eventData.errorCode = errorData.code
            eventData.errorMessage = errorData.message
            eventData.errorData = errorData.data
            // error data is only send in the payload once and then cleared from state machine
            stateMachine.setErrorData(error: nil)
        }
        sendEventData(eventData: eventData)
        
        stateMachine.resetVideoStartFailed()
    }
    
    func stateMachine(_ stateMachine: StateMachine, didExitBufferingWithDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData.buffered = duration
        sendEventData(eventData: eventData)
    }

    func stateMachineDidEnterError(_ stateMachine: StateMachine) {
        let eventData = createEventData(duration: 0)
        
        if let errorData = stateMachine.getErrorData() {
            eventData.errorCode = errorData.code
            eventData.errorMessage = errorData.message
            eventData.errorData = errorData.data
            // error data is only send in the payload once and then cleared from state machine
            stateMachine.setErrorData(error: nil)
        }
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didExitPlayingWithDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData.played = duration
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didExitPauseWithDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData.paused = duration
        sendEventData(eventData: eventData)
    }

    func stateMachineDidQualityChange(_ stateMachine: StateMachine) {
        let eventData = createEventData(duration: 0)
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didExitSeekingWithDuration duration: Int64, destinationPlayerState: PlayerState) {
        let eventData = createEventData(duration: duration)
        eventData.seeked = duration
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didHeartbeatWithDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        switch stateMachine.state {
        case .playing:
            eventData.played = duration

        case .paused:
            eventData.paused = duration

        case .buffering:
            eventData.buffered = duration

        default:
            break
        }
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didStartupWithDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData.videoStartupTime = duration
        // Hard coding 1 as the player startup time to workaround a Dashboard issue
        eventData.playerStartupTime = 1
        eventData.startupTime = duration + 1
        eventData.supportedVideoCodecs = Util.getSupportedVideoCodecs()
        eventData.state = "startup"
        sendEventData(eventData: eventData)
    }

    func stateMachineDidSubtitleChange(_ stateMachine: StateMachine) {
        let eventData = createEventData(duration: 0)
        sendEventData(eventData: eventData)
    }

    func stateMachineDidAudioChange(_ stateMachine: StateMachine) {
        let eventData = createEventData(duration: 0)
        sendEventData(eventData: eventData)
    }
    
    func stateMachineResetSourceState() {
        adapter?.resetSourceState()
        reset()
    }
    
    func stateMachineStopsCollecting() {
        detachPlayer()
    }

    var currentTime: CMTime? {
        get {
            return self.adapter?.currentTime
        }
    }
}
