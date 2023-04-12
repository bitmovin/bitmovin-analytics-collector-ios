import Foundation

internal class EventDataDispatcherFactory {
    private let httpClient: HttpClient
    private let authenticationService: AuthenticationService
    private let notificationCenter: NotificationCenter

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
                innerDispatcher: httpDispatcher
            )
        }

        return AuthenticatedDispatcher(
            authenticationService: authenticationService,
            notificationCenter: notificationCenter,
            innerDispatcher: httpDispatcher
        )
    }
}
