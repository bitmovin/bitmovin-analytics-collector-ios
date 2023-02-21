import Foundation

internal class HttpEventDataDispatcher: EventDataDispatcher {
    private let httpClient: HttpClient

    private let analyticsBackendUrl: String
    private let adAnalyticsBackendUrl: String

    init(httpClient: HttpClient) {
        self.httpClient = httpClient

        self.analyticsBackendUrl = BitmovinAnalyticsConfig.analyticsUrl
        self.adAnalyticsBackendUrl = BitmovinAnalyticsConfig.adAnalyticsUrl
    }

    func add(_ eventData: EventData) {
        let json = Util.toJson(object: eventData)
        print("send payload: " + json.replacingOccurrences(of: ",", with: "\n\t"))
        httpClient.post(urlString: self.analyticsBackendUrl, json: eventData.jsonString(), completionHandler: nil)
    }

    func addAd(_ adEventData: AdEventData) {
        let json = Util.toJson(object: adEventData)
        print("send Ad payload: " + json)
        httpClient.post(urlString: self.adAnalyticsBackendUrl, json: json, completionHandler: nil)
    }

    func disable() {
    }

    func resetSourceState() {
    }
}
