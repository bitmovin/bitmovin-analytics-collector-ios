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
        let eventDataQueue = persistentQueueFactory.create()
        let httpDispatcher = HttpEventDataDispatcher(httpClient: httpClient, eventDataQueue: eventDataQueue)

        if config.offlinePlaybackAnalyticsEnabled {
            let persistingDispatcher = PersistingDispatcher(
                innerDispatcher: httpDispatcher,
                eventDataQueue: eventDataQueue
            )

            return PersistingAuthenticatedDispatcher(
                authenticationService: authenticationService,
                notificationCenter: notificationCenter,
                innerDispatcher: persistingDispatcher,
                eventDataQueue: eventDataQueue
            )
        }

        return AuthenticatedDispatcher(
            authenticationService: authenticationService,
            notificationCenter: notificationCenter,
            innerDispatcher: httpDispatcher
        )
    }
}
