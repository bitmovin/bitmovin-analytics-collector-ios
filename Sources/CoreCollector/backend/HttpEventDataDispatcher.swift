import Foundation

internal class HttpEventDataDispatcher: EventDataDispatcher {
    private let logger = _AnalyticsLogger(className: "HttpEventDataDispatcher")
    private let httpClient: HttpClient
    private let eventDataQueue: PersistentEventDataQueue
    private let analyticsBackendUrl: String
    private let adAnalyticsBackendUrl: String
    private var isEnabled: Bool = true

    init(httpClient: HttpClient, eventDataQueue: PersistentEventDataQueue) {
        self.httpClient = httpClient
        self.eventDataQueue = eventDataQueue

        self.analyticsBackendUrl = BitmovinAnalyticsConfig.analyticsUrl
        self.adAnalyticsBackendUrl = BitmovinAnalyticsConfig.adAnalyticsUrl
    }

    func add(_ eventData: EventData) {
        guard isEnabled else { return }

        add(eventData) { _ in }
    }

    func addAd(_ adEventData: AdEventData) {
        guard isEnabled else { return }

        addAd(adEventData) { _ in }
    }

    func disable() {
        isEnabled = false
    }

    func resetSourceState() { /* no-op */ }
}

extension HttpEventDataDispatcher: CallbackEventDataDispatcher {
    func add(_ eventData: EventData, completionHandler: @escaping (HttpDispatchResult) -> Void) {
        guard isEnabled else { return }

        let json = Util.toJson(object: eventData)
        logger.d("send payload: \(json.replacingOccurrences(of: ",", with: "\n\t"))")

        httpClient.post(
            urlString: analyticsBackendUrl,
            json: eventData.jsonString()
        ) { [weak self] data, response, error in
            guard let self else { return }

            let result = HttpDispatchResult.from(data: data, response: response, error: error)

            if case .success = result {
                self.sendPersistedEventData()
            }

            completionHandler(result)
        }
    }

    func addAd(_ adEventData: AdEventData, completionHandler: @escaping (HttpDispatchResult) -> Void) {
        guard isEnabled else { return }

        let json = Util.toJson(object: adEventData)
        logger.d("send Ad payload: \(json)")

        httpClient.post(
            urlString: adAnalyticsBackendUrl,
            json: json
        ) { [weak self] data, response, error in
            guard let self else { return }

            let result = HttpDispatchResult.from(data: data, response: response, error: error)

            if case .success = result {
                self.sendPersistedEventData()
            }

            completionHandler(result)
        }
    }
}

extension HttpEventDataDispatcher: ResendingDispatcher {
    func sendPersistedEventData() {
        Task {
            if let next = await eventDataQueue.removeFirst() {
                logger.d("Retrying sending persisted event data")
                add(next)
                return
            }

            if let nextAd = await eventDataQueue.removeFirstAd() {
                logger.d("Retrying sending persisted ad event data")
                addAd(nextAd)
            }
        }
    }
}
