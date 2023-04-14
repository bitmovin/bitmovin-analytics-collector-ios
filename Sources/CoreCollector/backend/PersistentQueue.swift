import Foundation

internal class PersistentQueue<T: Codable & Equatable> {
    private struct Store: Codable {
        var entries: [T] = []
    }

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
            } catch {
                // TODO: handle error
            }
            return
        }

        cache = Store()
        try? ensureDirectoryExists()
    }

    private func ensureDirectoryExists() throws {
        try serialQueue.sync {
            let directoryURL = fileUrl.deletingLastPathComponent()
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
        try serialQueue.sync {
            let data = try JSONEncoder().encode(store)
            try data.write(to: fileUrl, options: .atomic)
        }
    }

    func add(entry: T) {
        serialQueue.sync {
            cache.entries.append(entry)
            try? persistStore(cache)
        }
    }

    func addAll(entries: [T]) {
        serialQueue.sync {
            cache.entries.append(contentsOf: entries)
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

    func update(entry: T) {
        serialQueue.sync {
            if let index = cache.entries.firstIndex(of: entry) {
                cache.entries[index] = entry
                try? persistStore(cache)
            }
        }
    }

    func all() -> [T] {
        serialQueue.sync {
            cache.entries
        }
    }
}
