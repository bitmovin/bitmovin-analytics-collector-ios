import Foundation

class PersistingAuthenticatedDispatcher: EventDataDispatcher {
    private enum OperationMode {
        case unauthenticated
        case authenticated
        case denied
    }

    private let logger = _AnalyticsLogger(className: "PersistingAuthenticatedDispatcher")
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

        addObserver(authenticationService)
    }

    deinit {
        removeObserver()
    }

    func add(_ eventData: EventData) {
        guard currentOperationMode != .denied else { return }
        guard currentOperationMode == .authenticated else {
            logger.d("Received event data but not authenticated. Trying to authenticate")
            Task { [weak self] in
                guard let self else { return }

                await self.eventDataQueue.add(eventData)
                self.authenticationService.authenticate()
            }
            return
        }

        innerDispatcher.add(eventData)
    }

    func addAd(_ adEventData: AdEventData) {
        guard currentOperationMode != .denied else { return }
        guard currentOperationMode == .authenticated else {
            logger.d("Received ad event data but not authenticated. Trying to authenticate")
            Task { [weak self] in
                guard let self else { return }

                await self.eventDataQueue.addAd(adEventData)
                self.authenticationService.authenticate()
            }
            return
        }

        innerDispatcher.addAd(adEventData)
    }

    func disable() {
        currentOperationMode = .unauthenticated
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
        notificationCenter.addObserver(
            self,
            selector: #selector(self.handleAuthenticationError),
            name: .authenticationError,
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

        innerDispatcher.sendPersistedEventData()
    }

    @objc
    func handleAuthenticationDenied(_ notification: Notification) {
        logger.d("Authentication denied")
        currentOperationMode = .denied

        Task { [weak self] in
            guard let self else { return }

            await self.eventDataQueue.removeAll()
        }
    }

    @objc
    func handleAuthenticationError(_ notification: Notification) {
        logger.d("Authentication error")
        currentOperationMode = .unauthenticated
    }
}
