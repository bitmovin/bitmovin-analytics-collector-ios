import Foundation

private let bitmovinOfflineStoragePath = "com.bitmovin.player/offline"
private let eventDataOfflineStorageFile = "eventData.json"
private let adEventDataOfflineStorageFile = "adEventData.json"

internal class PersistentQueueFactory {
    private lazy var baseDirectory: URL = {
        guard let applicationSupportDirectory = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            // Fallback to temporary directory if application support directory is not accessible
            return FileManager.default.temporaryDirectory.appendingPathComponent(bitmovinOfflineStoragePath)
        }

        return applicationSupportDirectory.appendingPathComponent(bitmovinOfflineStoragePath)
    }()

    private func createForEventData() -> PersistentQueue<EventData, EventDataKey> {
        PersistentQueue<EventData, EventDataKey>(
            fileUrl: baseDirectory.appendingPathComponent(eventDataOfflineStorageFile)
        )
    }

    private func createForAdEventData() -> PersistentQueue<AdEventData, EventDataKey> {
        PersistentQueue<AdEventData, EventDataKey>(
            fileUrl: baseDirectory.appendingPathComponent(adEventDataOfflineStorageFile)
        )
    }

    func create() -> PersistentEventDataQueue {
        PersistentEventDataQueue(
            eventDataQueue: createForEventData(),
            adEventDataQueue: createForAdEventData()
        )
    }
}
