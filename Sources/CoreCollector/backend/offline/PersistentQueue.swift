import Foundation

private let separator = Data("#".utf8)

internal class PersistentQueue<Payload: Codable & KeyDerivable, Key: LosslessStringConvertible> {
    private let logger = _AnalyticsLogger(className: "PersistentQueue")
    private let fileReaderWriter = FileReaderWriter()
    private var databaseInitialized: Bool = false
    private let fileUrl: URL
    private var fileExists: Bool {
        FileManager.default.fileExists(atPath: fileUrl.path)
    }
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @PersistentQueueActor
    var count: Int {
        ensureDatabaseInitialized()
        return fileReaderWriter.numberOfLines(in: fileUrl)
    }

    init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }

    @PersistentQueueActor
    func add(_ payload: Payload) {
        ensureDatabaseInitialized()

        guard let payloadData = try? encoder.encode(payload), let keys = payload.queueKey else { return }

        let line = Data(keys.description.utf8) + separator + payloadData
        fileReaderWriter.appendLine(line, to: fileUrl)
    }

    @PersistentQueueActor
    func removeAll() {
        ensureDatabaseInitialized()

        fileReaderWriter.writeEmptyFile(to: fileUrl)
    }

    @PersistentQueueActor
    func removeAll(where shouldRemove: (Key) -> Bool) {
        ensureDatabaseInitialized()

        guard let fileHandle = try? FileHandle(forReadingFrom: fileUrl) else { return }

        var entriesToKeep = Data()
        while let nextEntry = fileReaderWriter.readLine(from: fileHandle), !nextEntry.isEmpty {
            guard let key = parseKey(from: nextEntry) else { continue }

            if shouldRemove(key) {
                continue
            }

            entriesToKeep.append(nextEntry)
        }

        fileHandle.closeFile()
        fileReaderWriter.overwrite(file: fileUrl, with: entriesToKeep)
    }

    @PersistentQueueActor
    func removeFirst() -> Payload? {
        ensureDatabaseInitialized()

        guard let firstEntry = fileReaderWriter.removeFirstLine(from: fileUrl), !firstEntry.isEmpty else {
            return nil
        }

        guard let payloadData = parsePayloadData(from: firstEntry) else {
            return nil
        }

        return try? decoder.decode(Payload.self, from: payloadData)
    }

    @PersistentQueueActor
    func forEach(body: (Key) -> Void) {
        ensureDatabaseInitialized()

        guard let fileHandle = try? FileHandle(forReadingFrom: fileUrl) else { return }
        defer {
            fileHandle.closeFile()
        }

        while let nextEntry = fileReaderWriter.readLine(from: fileHandle), !nextEntry.isEmpty {
            guard let key = parseKey(from: nextEntry) else { continue }

            body(key)
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
                guard parseKey(from: firstEntry) != nil else { return false }
                guard let payloadData = parsePayloadData(from: firstEntry) else { return false }
                _ = try decoder.decode(Payload.self, from: payloadData)
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

    private func parseKey(from entry: Data) -> Key? {
        guard let range = entry[entry.startIndex...].range(of: separator), !range.isEmpty else { return nil }
        guard let keyString = String(data: entry[entry.startIndex..<range.lowerBound], encoding: .utf8) else { return nil }

        return Key.init(keyString)
    }

    private func parsePayloadData(from entry: Data) -> Data? {
        guard let range = entry[entry.startIndex...].range(of: separator), !range.isEmpty else { return nil }
        return entry[range.upperBound...]
    }
}
