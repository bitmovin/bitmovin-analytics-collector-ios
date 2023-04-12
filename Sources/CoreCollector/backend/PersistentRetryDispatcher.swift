import Foundation

internal class PersistentRetryDispatcher: EventDataDispatcher {
    private let notificationCenter: NotificationCenter
    private let innerDispatcher: EventDataDispatcher & CallbackEventDataDispatcher
    // TODO: we need a tri-state to track the transitions from offline to online to not flush on every successful request
    private var isEnabled = true
    // TODO: needs to be persistent
    private var queue: [EventData] = []

    init(
        authenticationService: AuthenticationService,
        notificationCenter: NotificationCenter,
        innerDispatcher: EventDataDispatcher & CallbackEventDataDispatcher
    ) {
        self.notificationCenter = notificationCenter
        self.innerDispatcher = innerDispatcher

        self.addObserver(authenticationService)
    }

    deinit {
        self.removeObserver()
    }

    func add(_ eventData: EventData) {
        guard isEnabled else { return }

        innerDispatcher.add(eventData) { [weak self] result in
            switch result {
            case .success:
                self?.removeFromQueue(eventData: eventData)
                self?.flushQueue()
            case .failure:
                self?.addToQueue(eventData: eventData)
            }
        }
    }

    func addAd(_ adEventData: AdEventData) {
        guard isEnabled else { return }

        innerDispatcher.addAd(adEventData) { [weak self] result in
            switch result {
            case .success:
                self?.removeFromQueue(adEventData: adEventData)
                self?.flushQueue()
            case .failure:
                self?.addToQueue(adEventData: adEventData)
            }
        }
    }

    func disable() {
        isEnabled = false
        innerDispatcher.disable()
        clearQueue()
    }

    func resetSourceState() {
        innerDispatcher.resetSourceState()
    }
}

private extension PersistentRetryDispatcher {
    func flushQueue() {
        // TODO
    }

    func removeFromQueue(eventData: EventData) {
        // TODO
    }

    func removeFromQueue(adEventData: AdEventData) {
        // TODO
    }

    func addToQueue(eventData: EventData) {
        // TODO
    }

    func addToQueue(adEventData: AdEventData) {
        // TODO
    }

    func clearQueue() {
        queue = []
    }

    func addObserver(_ authenticationService: AuthenticationService) {
        notificationCenter.addObserver(
            self,
            selector: #selector(self.handleAuthenticationSuccess),
            name: .authenticationSuccess,
            object: authenticationService
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(self.handleAuthenticationDenied),
            name: .authenticationDenied,
            object: authenticationService
        )
    }

    func removeObserver() {
        notificationCenter.removeObserver(self)
    }

    @objc
    func handleAuthenticationSuccess(_ notification: Notification) {
        flushQueue()
    }

    @objc
    func handleAuthenticationDenied(_ notification: Notification) {
        disable()
    }
}
