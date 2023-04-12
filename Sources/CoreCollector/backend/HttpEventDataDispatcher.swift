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
        ) { [weak self] data, response, error in
            guard let self else { return }

            completionHandler(self.httpDispatchResult(for: data, response: response, error: error))
        }
    }

    func addAd(_ adEventData: AdEventData, completionHandler: @escaping (HttpDispatchResult) -> Void) {
        let json = Util.toJson(object: adEventData)
        logger.d("send Ad payload: \(json)")

        httpClient.post(
            urlString: adAnalyticsBackendUrl,
            json: json
        ) { [weak self] data, response, error in
            guard let self else { return }

            completionHandler(self.httpDispatchResult(for: data, response: response, error: error))
        }
    }

    func disable() {
    }

    func resetSourceState() {
    }
}

private extension HttpEventDataDispatcher {
    func httpDispatchResult(for data: Data?, response: URLResponse?, error: Error?) -> HttpDispatchResult {
        if let error {
            return .failure(code: nil, error: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(code: nil, error: nil)
        }

        let statusCode = httpResponse.statusCode

        guard (200..<300).contains(statusCode) else {
            return .failure(code: statusCode, error: nil)
        }

        return .success(code: statusCode)

    }
}
