internal protocol CallbackEventDataDispatcher {
    func add(_ eventData: EventData, completionHandler: @escaping (HttpDispatchResult) -> Void)
    func addAd(_ adEventData: AdEventData, completionHandler: @escaping (HttpDispatchResult) -> Void)
}
