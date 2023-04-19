import Foundation

internal class PersistentEventDataQueue {
    private let eventDataQueue: PersistentQueue<EventData>
    private let adEventDataQueue: PersistentQueue<AdEventData>
    private let maxSequenceNumber: Int = 1_000
    private let maxEntries: Int = 10_000
    private let maxEntryAge: TimeInterval = 60 * 60 * 24 * 30 // 30 days in seconds

    init(
        eventDataQueue: PersistentQueue<EventData>,
        adEventDataQueue: PersistentQueue<AdEventData>
    ) {
        self.eventDataQueue = eventDataQueue
        self.adEventDataQueue = adEventDataQueue
    }

    func add(_ eventData: EventData) {
        guard eventData.sequenceNumber <= maxSequenceNumber else { return }

        while eventDataQueue.count >= maxEntries {
            _ = eventDataQueue.removeFirst()
        }

        eventDataQueue.add(entry: eventData)
    }

    func addAd(_ adEventData: AdEventData) {
        while adEventDataQueue.count >= maxEntries {
            _ = eventDataQueue.removeFirst()
        }

        adEventDataQueue.add(entry: adEventData)
    }

    func removeFirst() -> EventData? {
        guard let next = eventDataQueue.removeFirst() else { return nil }

        if next.age <= maxEntryAge {
            return next
        }

        return removeFirst()
    }

    func removeFirstAd() -> AdEventData? {
        guard let next = adEventDataQueue.removeFirst() else { return nil }

        if next.age <= maxEntryAge {
            return next
        }

        return removeFirstAd()
    }

    func removeAll() {
        eventDataQueue.removeAll()
        adEventDataQueue.removeAll()
    }
}

private extension EventData {
    var age: TimeInterval {
        guard let eventDataCreationTime = time else {
            return .nan
        }

        let ageMilliseconds = Date().timeIntervalSince1970Millis - eventDataCreationTime
        return Double(ageMilliseconds / 1_000)
    }
}

private extension AdEventData {
    var age: TimeInterval {
        guard let eventDataCreationTime = time else {
            return .nan
        }

        let ageMilliseconds = Date().timeIntervalSince1970Millis - eventDataCreationTime
        return Double(ageMilliseconds / 1_000)
    }
}
