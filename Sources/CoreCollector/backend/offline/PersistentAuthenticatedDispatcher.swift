import Foundation

class PersistentAuthenticatedDispatcher: EventDataDispatcher {
    private enum OperationMode {
        case unauthenticated
        case authenticated
        case disabled
    }

    private let logger = _AnalyticsLogger(className: "PersistentAuthenticatedDispatcher")
    private let authenticationService: AuthenticationService
    private let notificationCenter: NotificationCenter
    private let innerDispatcher: EventDataDispatcher & PersistentEventDataDispatcher
    private let eventDataQueue: PersistentEventDataQueue
    private var currentOperationMode: OperationMode = .unauthenticated

    init(
        authenticationService: AuthenticationService,
        notificationCenter: NotificationCenter,
        innerDispatcher: EventDataDispatcher & PersistentEventDataDispatcher,
        eventDataQueue: PersistentEventDataQueue
    ) {
        self.authenticationService = authenticationService
        self.notificationCenter = notificationCenter
        self.innerDispatcher = innerDispatcher
        self.eventDataQueue = eventDataQueue

        self.addObserver(authenticationService)
    }

    deinit {
        self.removeObserver()
    }

    func add(_ eventData: EventData) {
        guard currentOperationMode != .disabled else { return }
        guard currentOperationMode == .authenticated else {
            logger.d("Received event data but not authenticated. Trying to authenticate")
            eventDataQueue.add(eventData)
            authenticationService.authenticate()
            return
        }

        innerDispatcher.add(eventData)
    }

    func addAd(_ adEventData: AdEventData) {
        guard currentOperationMode != .disabled else { return }
        guard currentOperationMode == .authenticated else {
            logger.d("Received ad event data but not authenticated. Trying to authenticate")
            eventDataQueue.addAd(adEventData)
            authenticationService.authenticate()
            return
        }

        innerDispatcher.addAd(adEventData)
    }

    func disable() {
        currentOperationMode = .disabled
        innerDispatcher.disable()
    }

    func resetSourceState() {
        innerDispatcher.resetSourceState()
    }
}

private extension PersistentAuthenticatedDispatcher {
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
        logger.d("Authentication success")
        currentOperationMode = .authenticated

        innerDispatcher.sendQueuedEventData()
    }

    @objc
    func handleAuthenticationDenied(_ notification: Notification) {
        logger.d("Authentication denied")
        eventDataQueue.removeAll()
        disable()
    }
}
