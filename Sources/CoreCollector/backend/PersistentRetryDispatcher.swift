import Foundation

private let bitmovinOfflineStoragePath = "com.bitmovin.player/offline"

// TODO: Rename to something that conveys "offline" and maybe get rid of "retry" naming
// TODO: Maybe extract the authentication part to something like an `AuthenticatedOfflineDispatcher`. The persistent
// queue should be injected to here and the `AuthenticatedOfflineDispatcher` so that both can access it
internal class PersistentRetryDispatcher: EventDataDispatcher {
    private enum OperationMode {
        case unauthenticated
        case authenticated
        case disabled
    }

    private let authenticationService: AuthenticationService
    private let notificationCenter: NotificationCenter
    private let innerDispatcher: EventDataDispatcher & CallbackEventDataDispatcher
    private var currentOperationMode: OperationMode = .unauthenticated
    private let eventDataQueue: PersistentQueue<PersistentEventData>
    private let adEventDataQueue: PersistentQueue<PersistentAdEventData>

    init(
        authenticationService: AuthenticationService,
        notificationCenter: NotificationCenter,
        innerDispatcher: EventDataDispatcher & CallbackEventDataDispatcher
    ) {
        self.authenticationService = authenticationService
        self.notificationCenter = notificationCenter
        self.innerDispatcher = innerDispatcher

        var baseDirectory: URL
        if let applicationSupportDirectory = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) {
            baseDirectory = applicationSupportDirectory.appendingPathComponent(bitmovinOfflineStoragePath)
        } else {
            baseDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(bitmovinOfflineStoragePath)
        }

        self.eventDataQueue = PersistentQueue(fileUrl: baseDirectory.appendingPathComponent("eventData.json"))
        self.adEventDataQueue = PersistentQueue(fileUrl: baseDirectory.appendingPathComponent("adEventData.json"))

        self.addObserver(authenticationService)
    }

    deinit {
        self.removeObserver()
    }

    func add(_ eventData: EventData) {
        guard currentOperationMode != .disabled else { return }
        guard currentOperationMode == .authenticated else {
            eventDataQueue.add(entry: PersistentEventData(eventData: eventData))
            authenticationService.authenticate()
            return
        }

        innerDispatcher.add(eventData) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.sendQueuedEventData()
            case .failure:
                self.eventDataQueue.add(entry: PersistentEventData(eventData: eventData))
            }
        }
    }

    func addAd(_ adEventData: AdEventData) {
        guard currentOperationMode != .disabled else { return }
        guard currentOperationMode == .authenticated else {
            adEventDataQueue.add(entry: PersistentAdEventData(adEventData: adEventData))
            authenticationService.authenticate()
            return
        }

        innerDispatcher.addAd(adEventData) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.sendQueuedEventData()
            case .failure:
                self.adEventDataQueue.add(entry: PersistentAdEventData(adEventData: adEventData))
            }
        }
    }

    func disable() {
        currentOperationMode = .disabled
        innerDispatcher.disable()
        eventDataQueue.removeAll()
        adEventDataQueue.removeAll()
    }

    func resetSourceState() {
        innerDispatcher.resetSourceState()
    }
}

private extension PersistentRetryDispatcher {
    // TODO: send them one by one or all at once? We should weigh-in pros and cons
    func sendQueuedEventData() {
        if let next = eventDataQueue.next() {
            eventDataQueue.remove(entry: next)
            add(next.eventData)
            return
        }

        if let nextAd = adEventDataQueue.next() {
            adEventDataQueue.remove(entry: nextAd)
            addAd(nextAd.adEventData)
        }
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
        currentOperationMode = .authenticated
        sendQueuedEventData()
    }

    @objc
    func handleAuthenticationDenied(_ notification: Notification) {
        disable()
    }
}
