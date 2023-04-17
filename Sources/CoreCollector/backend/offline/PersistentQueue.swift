import Foundation

internal class PersistentQueue<T: Codable & Equatable> {
    private struct Store: Codable {
        var entries: [T] = []
    }

    private let logger = _AnalyticsLogger(className: "PersistentQueue")
    private let fileUrl: URL
    private let serialQueue: DispatchQueue
    private var cache: Store = Store()
    private var fileExists: Bool {
        FileManager.default.fileExists(atPath: fileUrl.path)
    }

    init(fileUrl: URL) {
        self.fileUrl = fileUrl
        self.serialQueue = DispatchQueue(label: "com.bitmovin.core-collector.persistence-queue")

        initPersistentStorage()
    }

    private func initPersistentStorage() {
        guard !fileExists else {
            do {
                cache = try fetchStore()
                logger.d("Fetched persisted data into local cache. Found \(cache.entries.count) entries at \(fileUrl)")
            } catch {
                logger.e("Failed to fetch persisted data")
                createNewPersistentStore()
            }
            return
        }

        createNewPersistentStore()
    }

    private func createNewPersistentStore() {
        logger.d("Creating new store")
        cache = Store()

        try? ensureDirectoryExists()
        try? persistStore(cache)
    }

    private func ensureDirectoryExists() throws {
        try serialQueue.sync {
            let directoryURL = fileUrl.deletingLastPathComponent()
            logger.d("Ensuring that directory \(directoryURL) exists")

            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }

    private func fetchStore() throws -> Store {
        try serialQueue.sync {
            let data = try Data(contentsOf: fileUrl)
            return try JSONDecoder().decode(Store.self, from: data)
        }
    }

    private func persistStore(_ store: Store) throws {
        let data = try JSONEncoder().encode(store)
        try data.write(to: fileUrl, options: .atomic)

        logger.d("Data written to disk. Store has \(store.entries.count) entries stored at \(fileUrl)")
    }

    func add(entry: T) {
        serialQueue.sync {
            cache.entries.append(entry)
            try? persistStore(cache)
        }
    }

    func remove(entry: T) {
        serialQueue.sync {
            if let index = cache.entries.firstIndex(of: entry) {
                cache.entries.remove(at: index)
                try? persistStore(cache)
            }
        }
    }

    func removeAll() {
        serialQueue.sync {
            cache.entries = []
            try? persistStore(cache)
        }
    }

    func next() -> T? {
        serialQueue.sync {
            cache.entries.first
        }
    }
}
