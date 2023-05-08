import Foundation

internal class PersistentQueue<T: Codable> {
    private let logger = _AnalyticsLogger(className: "PersistentQueue")
    private let fileReaderWriter = FileReaderWriter()
    private var databaseInitialized: Bool = false
    private let fileUrl: URL
    private var fileExists: Bool {
        FileManager.default.fileExists(atPath: fileUrl.path)
    }

    @PersistentQueueActor
    var count: Int {
        ensureDatabaseInitialized()
        return fileReaderWriter.numberOfLines(in: fileUrl)
    }

    init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }

    @PersistentQueueActor
    func add(entry: T) {
        ensureDatabaseInitialized()

        if let data = try? JSONEncoder().encode(entry) {
            fileReaderWriter.appendLine(data, to: fileUrl)
        }
    }

    @PersistentQueueActor
    func removeAll() {
        ensureDatabaseInitialized()

        fileReaderWriter.writeEmptyFile(to: fileUrl)
    }

    @PersistentQueueActor
    func removeAll(where shouldRemove: (T) -> Bool) {
        ensureDatabaseInitialized()

        guard let fileHandle = try? FileHandle(forReadingFrom: fileUrl) else { return }

        var entriesToKeep = Data()
        while let nextEntry = fileReaderWriter.readLine(from: fileHandle) {
            guard let decodedEntry = try? JSONDecoder().decode(T.self, from: nextEntry) else { continue }

            if shouldRemove(decodedEntry) {
                continue
            }

            entriesToKeep.append(nextEntry)
        }

        fileHandle.closeFile()
        fileReaderWriter.overwrite(file: fileUrl, with: entriesToKeep)
    }

    @PersistentQueueActor
    func removeFirst() -> T? {
        ensureDatabaseInitialized()

        guard let firstEntry = fileReaderWriter.removeFirstLine(from: fileUrl) else {
            return nil
        }

        return try? JSONDecoder().decode(T.self, from: firstEntry)
    }

    @PersistentQueueActor
    func forEach(body: (T) -> Void) {
        ensureDatabaseInitialized()

        guard let fileHandle = try? FileHandle(forReadingFrom: fileUrl) else { return }
        defer {
            fileHandle.closeFile()
        }

        while let nextEntry = fileReaderWriter.readLine(from: fileHandle) {
            guard let decodedEntry = try? JSONDecoder().decode(T.self, from: nextEntry) else { continue }
            body(decodedEntry)
        }
    }
}

@PersistentQueueActor
private extension PersistentQueue {
    private func ensureDatabaseInitialized() {
        guard !databaseInitialized else { return }
        defer {
            databaseInitialized = true
        }

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
        try? ensureDirectoryExists()
        fileReaderWriter.writeEmptyFile(to: fileUrl)

        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true

        var fileUrl = fileUrl
        try? fileUrl.setResourceValues(resourceValues)
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
