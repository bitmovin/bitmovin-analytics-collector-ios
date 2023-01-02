import Foundation

class SimpleEventDataDispatcher: EventDataDispatcher {
    private let httpClient: HttpClient
    private let config: BitmovinAnalyticsConfig
    private let notificationCenter: NotificationCenter
    
    private var enabled: Bool = false
    private var events = [EventData]()
    private var adEvents = [AdEventData]()
    private var sequenceNumber: Int32 = 0
    
    private var analyticsBackendUrl: String
    private var adAnalyticsBackendUrl: String

    init(config: BitmovinAnalyticsConfig, httpClient: HttpClient, authenticationService: AuthenticationService, notificationCenter: NotificationCenter) {
        self.httpClient = httpClient
        self.config = config
        self.analyticsBackendUrl = BitmovinAnalyticsConfig.analyticsUrl
        self.adAnalyticsBackendUrl = BitmovinAnalyticsConfig.adAnalyticsUrl
        self.notificationCenter = notificationCenter
        
        self.setupObserver(authenticationService)
    }
    
    deinit {
        self.removeObserver()
    }

    public func disable() {
        enabled = false
        self.sequenceNumber = 0
    }

    public func add(eventData: EventData) {
        eventData.sequenceNumber = self.sequenceNumber
        self.sequenceNumber += 1
        
        let json = Util.toJson(object: eventData)
        print("send payload: " + json.replacingOccurrences(of: ",", with: "\n\t"))
        
        if enabled {
            httpClient.post(urlString: self.analyticsBackendUrl, json: eventData.jsonString(), completionHandler: nil)
        } else {
            events.append(eventData)
        }
    }
    
    public func addAd(adEventData: AdEventData) {
        if enabled {
            let json = Util.toJson(object: adEventData)
            print("send Ad payload: " + json)
            httpClient.post(urlString: self.adAnalyticsBackendUrl, json: json, completionHandler: nil)
        } else {
            adEvents.append(adEventData)
        }
    }
    
    public func resetSourceState() {
        self.sequenceNumber = 0
    }
    
    private func setupObserver(_ authenticationService: AuthenticationService) {
        self.notificationCenter.addObserver(self, selector: #selector(self.handleAuthenticationSuccess), name: .authenticationSuccess, object: authenticationService)
        self.notificationCenter.addObserver(self, selector: #selector(self.handleAuthenticationFailed), name: .authenticationFailed, object: authenticationService)
    }
    
    private func removeObserver() {
        self.notificationCenter.removeObserver(self)
    }
    
    @objc private func handleAuthenticationSuccess(_ notification: Notification) {
        self.enabled = true
        self.flushEventQueues()
    }
    
    private func flushEventQueues() {
        let events = self.events.enumerated().reversed()
        for (index, eventData) in events {
            self.httpClient.post(urlString: self.analyticsBackendUrl, json: eventData.jsonString(), completionHandler: nil)
            self.events.remove(at: index)
        }
    
        let adEvents = self.adEvents.enumerated().reversed()
        for (index, adEventData) in adEvents {
            self.httpClient.post(urlString: self.adAnalyticsBackendUrl, json: Util.toJson(object: adEventData), completionHandler: nil)
            self.adEvents.remove(at: index)
        }
    }
        
    @objc private func handleAuthenticationFailed(_ notification: Notification) {
        self.disable()
    }
}
