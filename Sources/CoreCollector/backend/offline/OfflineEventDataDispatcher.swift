import Foundation

internal class OfflineEventDataDispatcher: EventDataDispatcher, PersistentEventDataDispatcher {
    private let logger = _AnalyticsLogger(className: "OfflineEventDataDispatcher")
    private let innerDispatcher: EventDataDispatcher & CallbackEventDataDispatcher
    private let eventDataQueue: PersistentQueue<PersistentEventData>
    private let adEventDataQueue: PersistentQueue<PersistentAdEventData>

    init(
        innerDispatcher: EventDataDispatcher & CallbackEventDataDispatcher,
        eventDataQueue: PersistentQueue<PersistentEventData>,
        adEventDataQueue: PersistentQueue<PersistentAdEventData>
    ) {
        self.innerDispatcher = innerDispatcher
        self.eventDataQueue = eventDataQueue
        self.adEventDataQueue = adEventDataQueue
    }

    func add(_ eventData: EventData) {
        innerDispatcher.add(eventData) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.sendQueuedEventData()
            case .failure:
                self.logger.d("Failed to send event data. Data is being persisted and retried later")
                self.eventDataQueue.add(entry: PersistentEventData(eventData: eventData))
            }
        }
    }

    func addAd(_ adEventData: AdEventData) {
        innerDispatcher.addAd(adEventData) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.sendQueuedEventData()
            case .failure:
                self.logger.d("Failed to send ad event data. Data is being persisted and retried later")
                self.adEventDataQueue.add(entry: PersistentAdEventData(adEventData: adEventData))
            }
        }
    }

    func disable() {
        innerDispatcher.disable()
    }

    func resetSourceState() {
        innerDispatcher.resetSourceState()
    }

    // TODO: send them one by one or all at once? We should weigh-in pros and cons
    func sendQueuedEventData() {
        if let next = eventDataQueue.next() {
            logger.d("Retrying sending persisted event data")
            eventDataQueue.remove(entry: next)
            add(next.eventData)
            return
        }

        if let nextAd = adEventDataQueue.next() {
            logger.d("Retrying sending persisted ad event data")
            adEventDataQueue.remove(entry: nextAd)
            addAd(nextAd.adEventData)
        }
    }
}
