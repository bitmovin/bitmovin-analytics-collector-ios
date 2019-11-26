import Foundation

class SimpleEventDataDispatcher: EventDataDispatcher {
    private var httpClient: HttpClient
    private var enabled: Bool = false
    private var events = [EventData]()
    private var config: BitmovinAnalyticsConfig
    private var sequenceNumber: Int32 = 0

    init(config: BitmovinAnalyticsConfig) {
        httpClient = HttpClient(urlString: BitmovinAnalyticsConfig.analyticsUrl)
        self.config = config
    }

    func makeLicenseCall() {
        let licenseCall = LicenseCall(config: config)
        licenseCall.authenticate { [weak self] success in
            if success {
                self?.enabled = true
                guard let events = self?.events.enumerated().reversed() else {
                    return
                }
                for (index, eventData) in events {
                    self?.httpClient.post(json: eventData.jsonString(), completionHandler: nil)
                    self?.events.remove(at: index)
                }
            } else {
                self?.enabled = false
                NotificationCenter.default.post(name: .licenseFailed, object: self)
            }
        }
    }

    func enable() {
        makeLicenseCall()
    }

    func disable() {
        enabled = false
        self.sequenceNumber = 0
    }

    func add(eventData: EventData) {
        eventData.sequenceNumber = self.sequenceNumber
        self.sequenceNumber += 1
        if enabled {
            httpClient.post(json: eventData.jsonString(), completionHandler: nil)
        } else {
            events.append(eventData)
        }
    }

    func clear() {
    }
}
