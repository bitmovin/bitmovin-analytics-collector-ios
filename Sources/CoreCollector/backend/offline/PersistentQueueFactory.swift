import Foundation

private let bitmovinOfflineStoragePath = "com.bitmovin.player/offline"
private let eventDataOfflineStorageFile = "eventData.json"
private let adEventDataOfflineStorageFile = "adEventData.json"

internal class PersistentQueueFactory {
    private lazy var baseDirectory: URL = {
        if let applicationSupportDirectory = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) {
            return applicationSupportDirectory.appendingPathComponent(bitmovinOfflineStoragePath)
        }

        return FileManager.default.temporaryDirectory.appendingPathComponent(bitmovinOfflineStoragePath)
    }()

    private func createForEventData() -> PersistentQueue<EventData> {
        PersistentQueue<EventData>(
            fileUrl: baseDirectory.appendingPathComponent(eventDataOfflineStorageFile)
        )
    }

    private func createForAdEventData() -> PersistentQueue<AdEventData> {
        PersistentQueue<AdEventData>(
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
