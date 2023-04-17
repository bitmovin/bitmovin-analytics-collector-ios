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

    func createForEventData() -> PersistentQueue<PersistentEventData> {
        PersistentQueue<PersistentEventData>(
            fileUrl: baseDirectory.appendingPathComponent(eventDataOfflineStorageFile)
        )
    }

    func createForAdEventData() -> PersistentQueue<PersistentAdEventData> {
        PersistentQueue<PersistentAdEventData>(
            fileUrl: baseDirectory.appendingPathComponent(adEventDataOfflineStorageFile)
        )
    }
}
