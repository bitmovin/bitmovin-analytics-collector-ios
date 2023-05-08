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

        if await eventDataQueue.count >= maxEntries {
            await cleanUpDatabase()
        }

        await eventDataQueue.add(entry: eventData)
        logger.d("Added event data to queue")
    }

    func addAd(_ adEventData: AdEventData) async {
        if await eventDataQueue.count >= maxEntries {
            await cleanUpDatabase()
        }

        await adEventDataQueue.add(entry: adEventData)
        logger.d("Added ad event data to queue")
    }

    func removeFirst() async -> EventData? {
        guard let eventData = await eventDataQueue.removeFirst() else { return nil }

        if eventData.age <= maxEntryAge {
            return eventData
        }

        logger.d("Entry exceeding max age found, discarding old sessions and fetching next")
        await cleanUpDatabase(including: eventData.impressionId)

        return await removeFirst()
    }

    func removeFirstAd() async -> AdEventData? {
        guard let adEventData = await adEventDataQueue.removeFirst() else { return nil }

        if adEventData.age <= maxEntryAge {
            return adEventData
        }

        logger.d("Entry exceeding max age found, discarding old sessions and fetching next")
        if let impressionId = adEventData.videoImpressionId {
            await cleanUpDatabase(including: impressionId)
        }

        return await removeFirstAd()
    }

    func removeAll() async {
        await eventDataQueue.removeAll()
        await adEventDataQueue.removeAll()
    }
}

private extension PersistentEventDataQueue {
    func cleanUpDatabase(including impressionId: String? = nil) async {
        logger.d("Cleaning up database")

        var impressionIdsToPurge = await findOldSessionsToPurge()
        if let impressionId {
            impressionIdsToPurge.insert(impressionId)
        }

        await purgeEntries(for: impressionIdsToPurge)

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
        guard !impressionIds.isEmpty else { return }

        logger.d("Purging entries for \(impressionIds.count) impression IDs")

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
