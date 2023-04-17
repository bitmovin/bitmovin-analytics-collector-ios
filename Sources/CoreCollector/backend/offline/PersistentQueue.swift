import Foundation

private let serialQueue = DispatchQueue(label: "com.bitmovin.core-collector.persistence-queue")

internal class PersistentQueue<T: Codable & Equatable> {
    private struct Store: Codable {
        var entries: [T] = []
    }

    private let logger = _AnalyticsLogger(className: "PersistentQueue")
    private let fileUrl: URL
    private var fileExists: Bool {
        FileManager.default.fileExists(atPath: fileUrl.path)
    }

    init(fileUrl: URL) {
        self.fileUrl = fileUrl

        initPersistentStorage()
    }

    private func initPersistentStorage() {
        guard !fileExists else {
            do {
                let _ = try fetchStore()
            } catch {
                logger.e("Failed to fetch persisted data, might be corrupted")
                createNewPersistentStore()
            }
            return
        }

        createNewPersistentStore()
    }

    private func createNewPersistentStore() {
        logger.d("Creating new store")
        serialQueue.sync {
            try? ensureDirectoryExists()
            try? persistStore(Store())
        }
    }

    private func ensureDirectoryExists() throws {
        let directoryURL = fileUrl.deletingLastPathComponent()
        logger.d("Ensuring that directory \(directoryURL) exists")

        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    private func fetchStore() throws -> Store {
        let data = try Data(contentsOf: fileUrl)
        return try JSONDecoder().decode(Store.self, from: data)
    }

    private func persistStore(_ store: Store) throws {
        let data = try JSONEncoder().encode(store)
        try data.write(to: fileUrl, options: .atomic)

        logger.d("Data written to disk. Store has \(store.entries.count) entries stored at \(fileUrl)")
    }

    func add(entry: T) {
        serialQueue.sync {
            guard var stored = try? fetchStore() else { return }
            stored.entries.append(entry)
            try? persistStore(stored)
        }
    }

    func removeAll() {
        serialQueue.sync {
            try? persistStore(Store())
        }
    }

    func removeFirst() -> T? {
        serialQueue.sync {
            guard var stored = try? fetchStore(),
                  let _ = stored.entries.first else {
                return nil
            }

            let first = stored.entries.removeFirst()
            try? persistStore(stored)

            return first
        }
    }
}
