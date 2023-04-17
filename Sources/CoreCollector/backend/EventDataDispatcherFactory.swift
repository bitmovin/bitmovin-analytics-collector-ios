import Foundation

internal class EventDataDispatcherFactory {
    private let httpClient: HttpClient
    private let authenticationService: AuthenticationService
    private let notificationCenter: NotificationCenter
    private let persistentQueueFactory = PersistentQueueFactory()

    init(
        _ httpClient: HttpClient,
        _ authenticationService: AuthenticationService,
        _ notificationCenter: NotificationCenter
    ) {
        self.httpClient = httpClient
        self.notificationCenter = notificationCenter
        self.authenticationService = authenticationService
    }

    func createDispatcher(config: BitmovinAnalyticsConfig) -> EventDataDispatcher {
        let httpDispatcher = HttpEventDataDispatcher(httpClient: httpClient)

        if config.offlinePlaybackAnalyticsEnabled {
            let eventDataQueue = persistentQueueFactory.createForEventData()
            let adEventDataQueue = persistentQueueFactory.createForAdEventData()

            let persistentRetryDispatcher = PersistentRetryDispatcher(
                innerDispatcher: httpDispatcher,
                eventDataQueue: eventDataQueue,
                adEventDataQueue: adEventDataQueue
            )

            return PersistentAuthenticatedDispatcher(
                authenticationService: authenticationService,
                notificationCenter: notificationCenter,
                innerDispatcher: persistentRetryDispatcher,
                eventDataQueue: eventDataQueue,
                adEventDataQueue: adEventDataQueue
            )
        }

        return AuthenticatedDispatcher(
            authenticationService: authenticationService,
            notificationCenter: notificationCenter,
            innerDispatcher: httpDispatcher
        )
    }
}
