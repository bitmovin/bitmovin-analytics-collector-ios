import Foundation

internal class PersistentEventDataQueue {
    private let eventDataQueue: PersistentQueue<EventData>
    private let adEventDataQueue: PersistentQueue<AdEventData>
    private let maxSequenceNumber: Int = 1000

    init(
        eventDataQueue: PersistentQueue<EventData>,
        adEventDataQueue: PersistentQueue<AdEventData>
    ) {
        self.eventDataQueue = eventDataQueue
        self.adEventDataQueue = adEventDataQueue
    }

    func add(_ eventData: EventData) {
        guard eventData.sequenceNumber <= maxSequenceNumber else { return }

        eventDataQueue.add(entry: eventData)
    }

    func addAd(_ adEventData: AdEventData) {
        adEventDataQueue.add(entry: adEventData)
    }

    func removeFirst() -> EventData? {
        eventDataQueue.removeFirst()
    }

    func removeFirstAd() -> AdEventData? {
        adEventDataQueue.removeFirst()
    }

    func removeAll() {
        eventDataQueue.removeAll()
        adEventDataQueue.removeAll()
    }
}
