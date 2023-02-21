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

    func createDispatcher() -> EventDataDispatcher {
        let httpDispatcher = HttpEventDataDispatcher(httpClient: self.httpClient)

        let authDispatcher = AuthenticatedDispatcher(
            authenticationService: self.authenticationService,
            httpClient: httpClient,
            notificationCenter: self.notificationCenter,
            innerDispatcher: httpDispatcher
        )

        return authDispatcher
    }
}
