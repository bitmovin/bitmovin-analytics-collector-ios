import Foundation

class PersistingAuthenticatedDispatcher: EventDataDispatcher {
    private enum OperationMode {
        case unauthenticated
        case authenticated
        case disabled
    }

    private let logger = _AnalyticsLogger(className: "PersistentAuthenticatedDispatcher")
    private let authenticationService: AuthenticationService
    private let notificationCenter: NotificationCenter
    private let innerDispatcher: EventDataDispatcher & ResendingDispatcher
    private let eventDataQueue: PersistentEventDataQueue
    private var currentOperationMode: OperationMode = .unauthenticated

    init(
        authenticationService: AuthenticationService,
        notificationCenter: NotificationCenter,
        innerDispatcher: EventDataDispatcher & ResendingDispatcher,
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
            Task {
                await eventDataQueue.add(eventData)
                authenticationService.authenticate()
            }
            return
        }

        innerDispatcher.add(eventData)
    }

    func addAd(_ adEventData: AdEventData) {
        guard currentOperationMode != .disabled else { return }
        guard currentOperationMode == .authenticated else {
            logger.d("Received ad event data but not authenticated. Trying to authenticate")
            Task {
                await eventDataQueue.addAd(adEventData)
                authenticationService.authenticate()
            }
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

private extension PersistingAuthenticatedDispatcher {
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

        Task {
            await innerDispatcher.sendPersistedEventData()
        }
    }

    @objc
    func handleAuthenticationDenied(_ notification: Notification) {
        logger.d("Authentication denied")
        disable()

        Task {
            await eventDataQueue.removeAll()
        }
    }
}
