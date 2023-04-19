import Foundation

internal class PersistingDispatcher: EventDataDispatcher, ResendingDispatcher {
    private let logger = _AnalyticsLogger(className: "OfflineEventDataDispatcher")
    private let innerDispatcher: EventDataDispatcher & CallbackEventDataDispatcher & ResendingDispatcher
    private let eventDataQueue: PersistentEventDataQueue

    init(
        innerDispatcher: EventDataDispatcher & CallbackEventDataDispatcher & ResendingDispatcher,
        eventDataQueue: PersistentEventDataQueue
    ) {
        self.innerDispatcher = innerDispatcher
        self.eventDataQueue = eventDataQueue
    }

    func add(_ eventData: EventData) {
        innerDispatcher.add(eventData) { [weak self] result in
            guard let self else { return }

            if case .failure = result {
                self.logger.d("Failed to send event data. Data is being persisted and retried later")
                self.eventDataQueue.add(eventData)
            }
        }
    }

    func addAd(_ adEventData: AdEventData) {
        innerDispatcher.addAd(adEventData) { [weak self] result in
            guard let self else { return }

            if case .failure = result {
                self.logger.d("Failed to send ad event data. Data is being persisted and retried later")
                self.eventDataQueue.addAd(adEventData)
            }
        }
    }

    func disable() {
        innerDispatcher.disable()
    }

    func resetSourceState() {
        innerDispatcher.resetSourceState()
    }

    func sendPersistedEventData() {
        innerDispatcher.sendPersistedEventData()
    }
}
