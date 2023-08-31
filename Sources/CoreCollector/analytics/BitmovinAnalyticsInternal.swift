import AVFoundation
import Foundation
import UIKit

/**
 * An iOS analytics plugin that sends video playback analytics to Bitmovin Analytics servers. Currently
 * supports analytics on AVPlayer video players
*/
public class BitmovinAnalyticsInternal: NSObject {
    public private(set) var adAnalytics: BitmovinAdAnalytics?

    internal var adapter: PlayerAdapter?
    internal var adAdapter: AdAdapter?

    private var config: BitmovinAnalyticsConfig

    // we want to get rid of it in this class
    private var stateMachine: DefaultStateMachine?
    private let eventDataDispatcher: EventDataDispatcher
    private let authenticationService: AuthenticationService
    private let eventDataFactory: EventDataFactory
    private let notificationCenter: NotificationCenter

    private var isPlayerAttached = false
    private var didSendDrmLoadTime = false

    convenience init(
        config: BitmovinAnalyticsConfig,
        eventDataFactory: EventDataFactory
    ) {
        let notificationCenter = NotificationCenter.default
        let httpClient = HttpClient()
        let authenticationService = LicenseAuthenticationService(httpClient, config, notificationCenter)
        let dispatcherFactory = EventDataDispatcherFactory(httpClient, authenticationService, notificationCenter)
        self.init(
            config,
            notificationCenter,
            dispatcherFactory.createDispatcher(config: config),
            authenticationService,
            eventDataFactory
        )
    }

    private init(
        _ config: BitmovinAnalyticsConfig,
        _ notificationCenter: NotificationCenter,
        _ eventDataDispatcher: EventDataDispatcher,
        _ authenticationService: AuthenticationService,
        _ eventDataFactory: EventDataFactory
    ) {
        self.config = config
        self.eventDataFactory = eventDataFactory
        self.notificationCenter = notificationCenter
        self.authenticationService = authenticationService
        self.eventDataDispatcher = eventDataDispatcher

        super.init()

        self.setupObservers()

        if config.ads {
            self.adAnalytics = BitmovinAdAnalytics(analytics: self)
        }
    }

    deinit {
        if let stateMachine = self.stateMachine, let state = self.stateMachine?.state {
            if state == .playing {
                let enterTimestamp = stateMachine.stateEnterTimestamp
                let duration = Date().timeIntervalSince1970Millis - enterTimestamp
                if duration < 90_000 {
                    stateMachine.videoTimeEnd = self.adapter?.currentTime
                    onPlayingExit(withDuration: duration)
                }
            }
        }

        self.removeObserver()
        self.detachPlayer()
    }

    /**
     * Detach the current player that is being used with Bitmovin Analytics.
     */
    public func detachPlayer() {
        guard isPlayerAttached else {
            return
        }
        eventDataFactory.clearEventDataManipulators()
        isPlayerAttached = false
        detachAd()
        adapter?.destroy()
        eventDataDispatcher.resetSourceState()
        eventDataDispatcher.disable()
        eventDataFactory.reset()
        stateMachine?.reset()
        stateMachine = nil
        adapter = nil
    }

    public func attach(adapter: PlayerAdapter) {
        if isPlayerAttached {
            detachPlayer()
        }
        isPlayerAttached = true
        stateMachine?.listener = self
        self.authenticationService.authenticate()
        self.adapter = adapter
        self.adapter?.initialize()
    }

    private func detachAd() {
        adAdapter?.releaseAdapter()
    }

    public func attachAd(adAdapter: AdAdapter) {
        self.adAdapter = adAdapter
    }

    public func setStateMachine(_ stateMachine: StateMachine) {
        guard let stateMachine = stateMachine as? DefaultStateMachine else {
            return
        }
        self.stateMachine = stateMachine
    }

    public func getCustomData() -> CustomData {
        let sourceMetadata = adapter?.currentSourceMetadata
        return sourceMetadata?.getCustomData() ?? self.config.getCustomData()
    }

    public func setCustomData(customData: CustomData) {
        guard self.adapter != nil else {
            return
        }
        let sourceMetadata = adapter?.currentSourceMetadata
        let customDataConfig: CustomDataConfig = sourceMetadata ?? self.config

        self.stateMachine?.changeCustomData(
            customData: customData,
            time: self.currentTime,
            customDataConfig: customDataConfig
        )
    }

    public func setCustomDataOnce(customData: CustomData) {
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
        eventDataDispatcher.add(data)
    }

    func sendAdEventData(adEventData: AdEventData?) {
        guard let data = adEventData else {
            return
        }
        eventDataDispatcher.addAd(data)
    }

    func createEventData(duration: Int64) -> EventData {
        let stateMachine = self.stateMachine!

        var drmLoadTime: Int64?
        if adapter?.drmDownloadTime != nil && !didSendDrmLoadTime {
            drmLoadTime = adapter?.drmDownloadTime
            didSendDrmLoadTime = true
        }

        let eventData = self.eventDataFactory.createEventData(
            stateMachine.state.rawValue,
            stateMachine.impressionId,
            stateMachine.videoTimeStart,
            stateMachine.videoTimeEnd,
            drmLoadTime,
            self.adapter?.currentSourceMetadata
        )

        if stateMachine.videoStartFailureService.videoStartFailed {
            eventData.videoStartFailed = stateMachine.videoStartFailureService.videoStartFailed
            eventData.videoStartFailedReason = stateMachine.videoStartFailureService.videoStartFailedReason
                ?? VideoStartFailedReason.unknown
            stateMachine.videoStartFailureService.reset()
        }

        eventData.duration = duration
        return eventData
    }

    internal func reset() {
        eventDataDispatcher.resetSourceState()
        eventDataFactory.reset()
        didSendDrmLoadTime = false
    }

    private func removeObserver() {
        self.notificationCenter.removeObserver(self, name: .authenticationDenied, object: self.authenticationService)
        self.notificationCenter.removeObserver(self, name: .authenticationError, object: self.authenticationService)
        self.notificationCenter.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }

    private func setupObservers() {
        self.notificationCenter.addObserver(
            self,
            selector: #selector(handleAuthenticationDenied(notification:)),
            name: .authenticationDenied,
            object: self.authenticationService
        )
        self.notificationCenter.addObserver(
            self,
            selector: #selector(handleAuthenticationError(notification:)),
            name: .authenticationError,
            object: self.authenticationService
        )
        self.notificationCenter.addObserver(
            self,
            selector: #selector(handleApplicationWillTerminate(notification:)),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    @objc
    private func handleAuthenticationDenied(notification _: Notification) {
        detachPlayer()
    }

    @objc
    private func handleAuthenticationError(notification _: Notification) {
        guard !config.longTermRetryEnabled else { return }
        detachPlayer()
    }

    @objc
    private func handleApplicationWillTerminate(notification _: Notification) {
        detachPlayer()
    }
}

extension BitmovinAnalyticsInternal: StateMachineListener {
    func onStartup(withDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData.videoStartupTime = duration
        // Hard coding 1 as the player startup time to workaround a Dashboard issue
        eventData.playerStartupTime = 1
        eventData.startupTime = duration + 1
        eventData.supportedVideoCodecs = CodecUtils.getSupportedVideoCodecs()
        eventData.state = "startup"
        sendEventData(eventData: eventData)
    }

    func onPauseExit(withDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData.paused = duration
        sendEventData(eventData: eventData)
    }

    func onPlayingExit(withDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData.played = duration
        sendEventData(eventData: eventData)
    }

    func onHeartbeat(withDuration duration: Int64, state: PlayerState) {
        let eventData = createEventData(duration: duration)
        switch state {
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

    func onRebuffering(withDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData.buffered = duration
        sendEventData(eventData: eventData)
    }

    func onError(_ stateMachine: StateMachine) {
        let eventData = createEventData(duration: 0)

        if let errorData = stateMachine.getErrorData() {
            eventData.errorCode = errorData.code
            eventData.errorMessage = errorData.message
            eventData.errorData = errorData.data
        }
        sendEventData(eventData: eventData)
    }

    func onSeekComplete(withDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData.seeked = duration
        sendEventData(eventData: eventData)
    }

    func onAdFinished(withDuration duration: Int64) {
        let eventData = createEventData(duration: duration)
        eventData.ad = 1
        sendEventData(eventData: eventData)
    }

    func onVideoQualityChanged() {
        let eventData = createEventData(duration: 0)
        sendEventData(eventData: eventData)
    }

    func onVideoStartFailed(_ stateMachine: StateMachine) {
        let eventData = createEventData(duration: 0)
        if let errorData = stateMachine.getErrorData() {
            eventData.errorCode = errorData.code
            eventData.errorMessage = errorData.message
            eventData.errorData = errorData.data
        }
        sendEventData(eventData: eventData)
    }

    func onSubtitleChanged() {
        let eventData = createEventData(duration: 0)
        sendEventData(eventData: eventData)
    }

    func onAudioQualityChanged() {
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
        self.adapter?.currentTime
    }
}

public extension BitmovinAnalyticsInternal {
    static func createAnalytics(
        config: BitmovinAnalyticsConfig,
        eventDataFactory: EventDataFactory
    ) -> BitmovinAnalyticsInternal {
        BitmovinAnalyticsInternal(
            config: config,
            eventDataFactory: eventDataFactory
        )
    }
}
