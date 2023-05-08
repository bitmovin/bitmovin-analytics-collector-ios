import Foundation

private let maxSequenceNumber: Int = 500
private let maxEntries: Int = 5_000
private let maxEntryAge: TimeInterval = 60 * 60 * 24 * 14 // 14 days in seconds

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

        await cleanUpDatabase()
        await eventDataQueue.add(entry: eventData)
        logger.d("Added event data to queue")
    }

    func addAd(_ adEventData: AdEventData) async {
        await cleanUpDatabase()
        await adEventDataQueue.add(entry: adEventData)
        logger.d("Added ad event data to queue")
    }

    func removeFirst() async -> EventData? {
        await cleanUpDatabase()
        return await eventDataQueue.removeFirst()
    }

    func removeFirstAd() async -> AdEventData? {
        await cleanUpDatabase()
        return await adEventDataQueue.removeFirst()
    }

    func removeAll() async {
        await eventDataQueue.removeAll()
        await adEventDataQueue.removeAll()
    }
}

private extension PersistentEventDataQueue {
    func cleanUpDatabase() async {
        await purgeEntries(for: await findOldSessionsToPurge())

        while await eventDataQueue.count >= maxEntries {
            guard let entryToPurge = await eventDataQueue.removeFirst() else { break }
            await purgeEntries(for: entryToPurge.impressionId)
        }
    }

    func findOldSessionsToPurge() async -> Set<String> {
        var sessionsToPurge: Set<String> = []

        await eventDataQueue.forEach { eventData in
            if eventData.age > maxEntryAge {
                sessionsToPurge.insert(eventData.impressionId)
            }
        }

        return sessionsToPurge
    }

    func purgeEntries(for impressionId: String) async {
        await purgeEntries(for: [impressionId])
    }

    func purgeEntries(for impressionIds: Set<String>) async {
        await eventDataQueue.removeAll { eventData in
            return impressionIds.contains(eventData.impressionId)
        }

        await adEventDataQueue.removeAll { adEventData in
            guard let impressionId = adEventData.videoImpressionId else { return true }
            return impressionIds.contains(impressionId)
        }
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
