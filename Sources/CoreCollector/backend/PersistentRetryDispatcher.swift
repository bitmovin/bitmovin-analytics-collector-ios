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
                flushQueue()
            }
        }
    }
    // TODO: needs to be persistent
    private var queue: [EventData] = []

    init(
        authenticationService: AuthenticationService,
        notificationCenter: NotificationCenter,
        innerDispatcher: EventDataDispatcher & CallbackEventDataDispatcher
    ) {
        self.authenticationService = authenticationService
        self.notificationCenter = notificationCenter
        self.innerDispatcher = innerDispatcher

        self.addObserver(authenticationService)
    }

    deinit {
        self.removeObserver()
    }

    func add(_ eventData: EventData) {
        guard currentOperationMode != .disabled else { return }
        guard currentOperationMode != .unauthenticated else {
            addToQueue(eventData: eventData)
            authenticationService.authenticate()
            return
        }

        innerDispatcher.add(eventData) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.removeFromQueue(eventData: eventData)
                self.currentOperationMode = .online
            case .failure:
                self.addToQueue(eventData: eventData)
                self.currentOperationMode = .offline
            }
        }
    }

    func addAd(_ adEventData: AdEventData) {
        guard currentOperationMode != .disabled else { return }
        guard currentOperationMode != .unauthenticated else {
            addToQueue(adEventData: adEventData)
            authenticationService.authenticate()
            return
        }

        innerDispatcher.addAd(adEventData) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.removeFromQueue(adEventData: adEventData)
                self.currentOperationMode = .online
            case .failure:
                self.addToQueue(adEventData: adEventData)
                self.currentOperationMode = .offline
            }
        }
    }

    func disable() {
        currentOperationMode = .disabled
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
        currentOperationMode = .online
    }

    @objc
    func handleAuthenticationDenied(_ notification: Notification) {
        disable()
    }
}
