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
            return PersistentRetryDispatcher(
                authenticationService: authenticationService,
                notificationCenter: notificationCenter,
                innerDispatcher: httpDispatcher,
                eventDataQueue: persistentQueueFactory.createForEventData(),
                adEventDataQueue: persistentQueueFactory.createForAdEventData()
            )
        }

        return AuthenticatedDispatcher(
            authenticationService: authenticationService,
            notificationCenter: notificationCenter,
            innerDispatcher: httpDispatcher
        )
    }
}
