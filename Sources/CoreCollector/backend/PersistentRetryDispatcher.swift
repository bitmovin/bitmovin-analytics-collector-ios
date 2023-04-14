import Foundation

// TODO: Rename to something that conveys "offline"
// TODO: Extract the authentication part to `AuthenticatedOfflineDispatcher`
internal class PersistentRetryDispatcher: EventDataDispatcher {
    private enum OperationMode {
        case online
        case offline
        case disabled
        case unauthenticated
    }

    private let authenticationService: AuthenticationService
    private let notificationCenter: NotificationCenter
    private let innerDispatcher: EventDataDispatcher & CallbackEventDataDispatcher
    private var currentOperationMode: OperationMode = .unauthenticated {
        didSet {
            if oldValue != .online, currentOperationMode == .online {
                sendQueuedEventData()
            }
        }
    }
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

        // TODO: use correct URLs
        self.eventDataQueue = PersistentQueue(fileUrl: URL(string: "")!)
        self.adEventDataQueue = PersistentQueue(fileUrl: URL(string: "")!)

        self.addObserver(authenticationService)
    }

    deinit {
        self.removeObserver()
    }

    func add(_ eventData: EventData) {
        guard currentOperationMode != .disabled else { return }
        guard currentOperationMode != .unauthenticated else {
            eventDataQueue.add(entry: PersistentEventData(eventData: eventData))
            authenticationService.authenticate()
            return
        }

        innerDispatcher.add(eventData) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.eventDataQueue.remove(entry: PersistentEventData(eventData: eventData))
                self.currentOperationMode = .online
            case .failure:
                self.eventDataQueue.add(entry: PersistentEventData(eventData: eventData))
                self.currentOperationMode = .offline
            }
        }
    }

    func addAd(_ adEventData: AdEventData) {
        guard currentOperationMode != .disabled else { return }
        guard currentOperationMode != .unauthenticated else {
            adEventDataQueue.add(entry: PersistentAdEventData(adEventData: adEventData))
            authenticationService.authenticate()
            return
        }

        innerDispatcher.addAd(adEventData) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.adEventDataQueue.remove(entry: PersistentAdEventData(adEventData: adEventData))
                self.currentOperationMode = .online
            case .failure:
                self.adEventDataQueue.add(entry: PersistentAdEventData(adEventData: adEventData))
                self.currentOperationMode = .offline
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
    func sendQueuedEventData() {
        eventDataQueue.all().forEach { persistentEventData in
            add(persistentEventData.eventData)
        }
        adEventDataQueue.all().forEach { persistentAdEventData in
            addAd(persistentAdEventData.adEventData)
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
        currentOperationMode = .online
    }

    @objc
    func handleAuthenticationDenied(_ notification: Notification) {
        disable()
    }
}
