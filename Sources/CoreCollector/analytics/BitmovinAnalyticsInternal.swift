import AVFoundation
import Foundation
import UIKit

/**
 * An iOS analytics plugin that sends video playback analytics to Bitmovin Analytics servers. Currently
 * supports analytics on AVPlayer video players
*/
open class BitmovinAnalyticsInternal: NSObject {
    public static let ErrorMessageKey = "errorMessage"
    public static let ErrorCodeKey = "errorCode"
    public static let ErrorDataKey = "errorData"
    public static let msInSec = 1_000.0
    
    public private(set) var config: BitmovinAnalyticsConfig
    public private(set) var stateMachine: StateMachine
    public private(set) var adAnalytics: BitmovinAdAnalytics?
    
    internal var adapter: PlayerAdapter?
    internal var adAdapter: AdAdapter?
    
    private let eventDataDispatcher: EventDataDispatcher
    private let authenticationService: AuthenticationService
    private let userIdProvider: UserIdProvider
    private let eventDataFactory: EventDataFactory
    private let notificationCenter: NotificationCenter
    
    private var isPlayerAttached = false
    internal var didSendDrmLoadTime = false
    
    public convenience init(config: BitmovinAnalyticsConfig) {
        let notificationCenter = NotificationCenter()
        let httpClient = HttpClient()
        let authenticationService = LicenseAuthenticationService(httpClient: httpClient, config: config, notificationCenter: notificationCenter)
        let dispatcherFactory = EventDataDispatcherFactory(httpClient: httpClient, authenticationService: authenticationService, notificationCenter: notificationCenter)
        let stateMachine = StateMachine(config: config)
        let userIdProvider: UserIdProvider = config.randomizeUserId ? RandomizedUserIdProvider() : UserDefaultUserIdProvider()
        let eventDataFactory = EventDataFactory(config, userIdProvider)
        self.init(config: config, notificationCenter: notificationCenter, eventDataDispatcher: dispatcherFactory.createDispatcher(), authenticationService: authenticationService, stateMachine: stateMachine, eventDataFactory: eventDataFactory,userIdProvider: userIdProvider)
    }
    
    internal init(
        config: BitmovinAnalyticsConfig,
        notificationCenter: NotificationCenter,
        eventDataDispatcher: EventDataDispatcher,
        authenticationService: AuthenticationService,
        stateMachine: StateMachine,
        eventDataFactory: EventDataFactory,
        userIdProvider: UserIdProvider
    ) {
        self.config = config
        self.stateMachine = stateMachine
        self.userIdProvider = userIdProvider
        self.eventDataFactory = eventDataFactory
        self.notificationCenter = notificationCenter
        self.authenticationService = authenticationService
        self.eventDataDispatcher = eventDataDispatcher
        
        super.init()
        
        self.setupObservers()
        
        if (config.ads) {
            self.adAnalytics = BitmovinAdAnalytics(analytics: self);
        }
    }
    
    deinit {
        if(self.stateMachine.state == .playing){
            let enterTimestamp = stateMachine.stateEnterTimestamp
            let duration = Date().timeIntervalSince1970Millis - enterTimestamp
            if (duration < 90000) {
                self.stateMachine.videoTimeEnd = self.adapter?.currentTime
                if(self.stateMachine.state == .playing){
                    stateMachine(self.stateMachine, didExitPlayingWithDuration: duration)
                }
            }
        }
        
        self.removeObserver()
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
        eventDataFactory.reset()
        stateMachine.reset()
        adapter = nil
    }

    public func attach(adapter: PlayerAdapter) {
        if isPlayerAttached {
            detachPlayer()
        }
        isPlayerAttached = true
        stateMachine.delegate = self
        self.authenticationService.authenticate()
        self.adapter = adapter
        self.adapter!.initialize()
    }
    
    private func detachAd() {
        adAdapter?.releaseAdapter()
    }
    
    public func attachAd(adAdapter: AdAdapter) {
        self.adAdapter = adAdapter;
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
    
    @objc public func getUserId() -> String {
        return userIdProvider.getUserId()
    }

    private func sendEventData(eventData: EventData?) {
        guard let data = eventData else {
            return
        }
        eventDataDispatcher.add(data)
    }
    
    internal func sendAdEventData(adEventData: AdEventData?) {
        guard let data = adEventData else {
            return
        }
        eventDataDispatcher.addAd(data)
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
            self.adapter?.currentSourceMetadata)
        
        do {
            try self.adapter?.decorateEventData(eventData: eventData)
        } catch {
            DPrint("There was an error during decorating EventData - data might be incomplete")
        }
        
        
        if self.stateMachine.videoStartFailureService.videoStartFailed {
            eventData.videoStartFailed = self.stateMachine.videoStartFailureService.videoStartFailed
            eventData.videoStartFailedReason = self.stateMachine.videoStartFailureService.videoStartFailedReason ?? VideoStartFailedReason.unknown
            stateMachine.videoStartFailureService.reset()
        }
        
        eventData.duration = duration
        return eventData
    }
    
    internal func reset(){
        eventDataDispatcher.resetSourceState()
        eventDataFactory.reset()
        didSendDrmLoadTime = false
    }
    
    private func removeObserver() {
        self.notificationCenter.removeObserver(self, name: .authenticationFailed, object: self.authenticationService)
        self.notificationCenter.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }
    
    private func setupObservers() {
        self.notificationCenter.addObserver(self, selector: #selector(handleAuthenticationFailed(notification:)), name: .authenticationFailed, object: self.authenticationService)
        self.notificationCenter.addObserver(self,
            selector: #selector(handleApplicationWillTerminate(notification:)),
            name: UIApplication.willTerminateNotification,
            object: nil)
    }
    
    @objc private func handleAuthenticationFailed(notification _: Notification) {
        detachPlayer()
    }
    
    @objc private func handleApplicationWillTerminate(notification _: Notification) {
        detachPlayer()
    }
}

extension BitmovinAnalyticsInternal: StateMachineDelegate {
    
    func stateMachine(_ stateMachine: StateMachine, didAdWithDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData.ad = 1
        sendEventData(eventData: eventData)
    }

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
    
    public var version: String {
        get {
            return Util.version()
        }
    }
}

extension BitmovinAnalyticsInternal {
    static public func createAnalytics(config: BitmovinAnalyticsConfig) -> BitmovinAnalyticsInternal {
        return BitmovinAnalyticsInternal(config: config)
    }
}
