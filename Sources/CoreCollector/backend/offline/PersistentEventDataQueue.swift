import Foundation

private let maxSequenceNumber: Int = 1_000
private let maxEntries: Int = 10_000
private let maxEntryAge: TimeInterval = 60 * 60 * 24 * 30 // 30 days in seconds

internal class PersistentEventDataQueue {
    private let logger = _AnalyticsLogger(className: "PersistentEventDataQueue")
    private let eventDataQueue: PersistentQueue<EventData>
    private let adEventDataQueue: PersistentQueue<AdEventData>

    init(
        eventDataQueue: PersistentQueue<EventData>,
        adEventDataQueue: PersistentQueue<AdEventData>
    ) {
        self.eventDataQueue = eventDataQueue
        self.adEventDataQueue = adEventDataQueue
    }

    func add(_ eventData: EventData) async {
        guard eventData.sequenceNumber <= maxSequenceNumber else { return }

        while await eventDataQueue.count >= maxEntries {
            _ = await eventDataQueue.removeFirst()
        }

        await eventDataQueue.add(entry: eventData)
        logger.d("Added event data to queue")
    }

    func addAd(_ adEventData: AdEventData) async {
        while await adEventDataQueue.count >= maxEntries {
            _ = await adEventDataQueue.removeFirst()
        }

        await adEventDataQueue.add(entry: adEventData)
        logger.d("Added ad event data to queue")
    }

    func removeFirst() async -> EventData? {
        guard let next = await eventDataQueue.removeFirst() else { return nil }

        if next.age <= maxEntryAge {
            return next
        }

        logger.d("Entry exceeding max age found, discarding and fetching next")
        return await removeFirst()
    }

    func removeFirstAd() async -> AdEventData? {
        guard let next = await adEventDataQueue.removeFirst() else { return nil }

        if next.age <= maxEntryAge {
            return next
        }

        logger.d("Entry exceeding max age found, discarding and fetching next")
        return await removeFirstAd()
    }

    func removeAll() async {
        await eventDataQueue.removeAll()
        await adEventDataQueue.removeAll()
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
