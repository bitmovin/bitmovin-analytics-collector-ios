import Foundation

internal class EventDataDispatcherFactory {
    
    private let httpClient: HttpClient
    private let authenticationService: AuthenticationService
    private let notificationCenter: NotificationCenter
    
    init(httpClient: HttpClient, authenticationService: AuthenticationService, notificationCenter: NotificationCenter) {
        self.httpClient = httpClient
        self.notificationCenter = notificationCenter
        self.authenticationService = authenticationService
    }
    
    public func createDispatcher() -> EventDataDispatcher {
        let httpDispatcher = HttpEventDataDispatcher(httpClient: self.httpClient)
        
        let authDispatcher = AuthenticatedDispatcher(authenticationService: self.authenticationService, httpClient: httpClient, notificationCenter: self.notificationCenter, innerDispatcher: httpDispatcher)
        
        return authDispatcher
    }
}
