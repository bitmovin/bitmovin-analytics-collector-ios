import Foundation

internal class HttpEventDataDispatcher: EventDataDispatcher, CallbackEventDataDispatcher {
    private let logger = _AnalyticsLogger(className: "HttpEventDataDispatcher")
    private let httpClient: HttpClient

    private let analyticsBackendUrl: String
    private let adAnalyticsBackendUrl: String

    init(httpClient: HttpClient) {
        self.httpClient = httpClient

        self.analyticsBackendUrl = BitmovinAnalyticsConfig.analyticsUrl
        self.adAnalyticsBackendUrl = BitmovinAnalyticsConfig.adAnalyticsUrl
    }

    func add(_ eventData: EventData) {
        add(eventData) { _ in }
    }

    func addAd(_ adEventData: AdEventData) {
        addAd(adEventData) { _ in }
    }

    func add(_ eventData: EventData, completionHandler: @escaping (HttpDispatchResult) -> Void) {
        let json = Util.toJson(object: eventData)
        logger.d("send payload: \(json.replacingOccurrences(of: ",", with: "\n\t"))")

        httpClient.post(
            urlString: analyticsBackendUrl,
            json: eventData.jsonString()
        ) { data, response, error in
            completionHandler(HttpDispatchResult.from(data: data, response: response, error: error))
        }
    }

    func addAd(_ adEventData: AdEventData, completionHandler: @escaping (HttpDispatchResult) -> Void) {
        let json = Util.toJson(object: adEventData)
        logger.d("send Ad payload: \(json)")

        httpClient.post(
            urlString: adAnalyticsBackendUrl,
            json: json
        ) { data, response, error in
            completionHandler(HttpDispatchResult.from(data: data, response: response, error: error))
        }
    }

    func disable() {
    }

    func resetSourceState() {
    }
}
