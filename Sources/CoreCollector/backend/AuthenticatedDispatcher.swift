import Foundation

internal class AuthenticatedDispatcher: EventDataDispatcher {
    private let notificationCenter: NotificationCenter
    private let innerDispatcher: EventDataDispatcher

    private var enabled = false
    private var events = [EventData]()
    private var adEvents = [AdEventData]()

    private var analyticsBackendUrl: String
    private var adAnalyticsBackendUrl: String

    init(
        authenticationService: AuthenticationService,
        notificationCenter: NotificationCenter,
        innerDispatcher: EventDataDispatcher
    ) {
        self.innerDispatcher = innerDispatcher
        self.notificationCenter = notificationCenter
        self.analyticsBackendUrl = BitmovinAnalyticsConfig.analyticsUrl
        self.adAnalyticsBackendUrl = BitmovinAnalyticsConfig.adAnalyticsUrl

        self.setupObserver(authenticationService)
    }

    deinit {
        self.removeObserver()
    }

    func add(_ eventData: EventData) {
        if enabled {
            innerDispatcher.add(eventData)
        } else {
            events.append(eventData)
        }
    }

    func addAd(_ adEventData: AdEventData) {
        if enabled {
            innerDispatcher.addAd(adEventData)
        } else {
            adEvents.append(adEventData)
        }
    }

    func disable() {
        enabled = false
        innerDispatcher.disable()
    }

    func resetSourceState() {
        innerDispatcher.resetSourceState()
    }

    private func setupObserver(_ authenticationService: AuthenticationService) {
        notificationCenter.addObserver(
            self,
            selector: #selector(self.handleAuthenticationSuccess),
            name: .authenticationSuccess,
            object: authenticationService
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(self.handleAuthenticationFailed),
            name: .authenticationFailed,
            object: authenticationService
        )
    }

    private func removeObserver() {
        notificationCenter.removeObserver(self)
    }

    @objc
    private func handleAuthenticationSuccess(_ notification: Notification) {
        enabled = true
        flushEventQueues()
    }

    private func flushEventQueues() {
        if !events.isEmpty {
            for eventData in events {
                innerDispatcher.add(eventData)
            }
            events.removeAll()
        }

        if !adEvents.isEmpty {
            for adEventData in adEvents {
                innerDispatcher.addAd(adEventData)
            }
            adEvents.removeAll()
        }
    }

    @objc
    private func handleAuthenticationFailed(_ notification: Notification) {
        disable()
    }
}
