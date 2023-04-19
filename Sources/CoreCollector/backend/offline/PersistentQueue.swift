import Foundation

private let serialQueue = DispatchQueue(label: "com.bitmovin.core-collector.persistence-queue")

internal class PersistentQueue<T: Codable> {
    private let logger = _AnalyticsLogger(className: "PersistentQueue")
    private let fileReaderWriter = FileReaderWriter()
    private let fileUrl: URL
    private var fileExists: Bool {
        FileManager.default.fileExists(atPath: fileUrl.path)
    }

    init(fileUrl: URL) {
        self.fileUrl = fileUrl

        initPersistentStorage()
    }

    func add(entry: T) {
        serialQueue.sync {
            if let data = try? JSONEncoder().encode(entry) {
                fileReaderWriter.appendLine(data, to: fileUrl)
            }
        }
    }

    func removeAll() {
        serialQueue.sync {
            fileReaderWriter.writeEmptyFile(to: fileUrl)
        }
    }

    func removeFirst() -> T? {
        serialQueue.sync {
            guard let next = fileReaderWriter.removeFirstLine(from: fileUrl) else {
                return nil
            }

            return try? JSONDecoder().decode(T.self, from: next)
        }
    }
}

private extension PersistentQueue {
    private func initPersistentStorage() {
        if fileExists {
            if !hasIntegrity() {
                createNewDatabase()
            }
        } else {
            createNewDatabase()
        }
    }

    private func createNewDatabase() {
        logger.d("Creating new database file")
        serialQueue.sync {
            try? ensureDirectoryExists()
            fileReaderWriter.writeEmptyFile(to: fileUrl)
        }
    }

    private func hasIntegrity() -> Bool {
        if let firstEntry = fileReaderWriter.readFirstLine(from: fileUrl) {
            do {
                _ = try JSONDecoder().decode(T.self, from: firstEntry)
            } catch {
                return false
            }

            return true
        }

        return true
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
}

