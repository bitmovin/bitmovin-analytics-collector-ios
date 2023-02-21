import Foundation

internal class AuthenticatedDispatcher: EventDataDispatcher {
    private let notificationCenter: NotificationCenter
    private let httpClient: HttpClient
    private let innerDispatcher: EventDataDispatcher

    private var enabled = false
    private var events = [EventData]()
    private var adEvents = [AdEventData]()

    private var analyticsBackendUrl: String
    private var adAnalyticsBackendUrl: String

    init(
        authenticationService: AuthenticationService,
        httpClient: HttpClient,
        notificationCenter: NotificationCenter,
        innerDispatcher: EventDataDispatcher
    ) {
        self.httpClient = httpClient
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
        self.enabled = false
        innerDispatcher.disable()
    }

    func resetSourceState() {
        innerDispatcher.resetSourceState()
    }

    private func setupObserver(_ authenticationService: AuthenticationService) {
        self.notificationCenter.addObserver(
            self,
            selector: #selector(self.handleAuthenticationSuccess),
            name: .authenticationSuccess,
            object: authenticationService
        )
        self.notificationCenter.addObserver(
            self,
            selector: #selector(self.handleAuthenticationFailed),
            name: .authenticationFailed,
            object: authenticationService
        )
    }

    private func removeObserver() {
        self.notificationCenter.removeObserver(self)
    }

    @objc
    private func handleAuthenticationSuccess(_ notification: Notification) {
        self.enabled = true
        self.flushEventQueues()
    }

    private func flushEventQueues() {
        let events = self.events.enumerated().reversed()
        for (index, eventData) in events {
            self.httpClient.post(
                urlString: self.analyticsBackendUrl,
                json: eventData.jsonString(),
                completionHandler: nil
            )
            self.events.remove(at: index)
        }

        let adEvents = self.adEvents.enumerated().reversed()
        for (index, adEventData) in adEvents {
            self.httpClient.post(
                urlString: self.adAnalyticsBackendUrl,
                json: Util.toJson(object: adEventData),
                completionHandler: nil
            )
            self.adEvents.remove(at: index)
        }
    }

    @objc
    private func handleAuthenticationFailed(_ notification: Notification) {
        self.disable()
    }
}
