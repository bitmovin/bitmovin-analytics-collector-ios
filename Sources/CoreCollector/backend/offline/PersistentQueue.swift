import Foundation

private let serialQueue = DispatchQueue(label: "com.bitmovin.core-collector.persistence-queue")

internal class PersistentQueue<T: Codable> {
    private let logger = _AnalyticsLogger(className: "PersistentQueue")
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
                appendLine(data, to: fileUrl)
            }
        }
    }

    func removeAll() {
        serialQueue.sync {
            writeEmptyFile(to: fileUrl)
        }
    }

    func removeFirst() -> T? {
        serialQueue.sync {
            guard let next = removeFirstLine(from: fileUrl) else {
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
            writeEmptyFile(to: fileUrl)
        }
    }

    private func hasIntegrity() -> Bool {
        if let firstEntry = readFirstLine(from: fileUrl) {
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

    func writeEmptyFile(to file: URL) {
        try? "".write(to: file, atomically: true, encoding: .utf8)
    }

    func appendLine(_ line: Data, to file: URL) {
        guard let fileHandle = try? FileHandle(forWritingTo: file) else { return }
        defer {
            fileHandle.closeFile()
        }

        fileHandle.seekToEndOfFile()

        guard let newLine = "\n".data(using: .utf8) else {
            return
        }

        var line = line
        line.append(newLine)
        fileHandle.write(line)
    }

    func readFirstLine(from file: URL) -> Data? {
        guard let fileHandle = try? FileHandle(forReadingFrom: file) else { return nil }
        defer {
            fileHandle.closeFile()
        }

        guard let line = fileHandle.readFirstLine() else {
            return nil
        }

        return line
    }

    func removeFirstLine(from file: URL) -> Data? {
        guard let fileHandle = try? FileHandle(forUpdating: file) else { return nil }
        guard let line = fileHandle.readFirstLine() else {
            fileHandle.closeFile()
            return nil
        }

        let remainingData = fileHandle.readDataToEndOfFile()
        fileHandle.closeFile()

        try? remainingData.write(to: file, options: .atomic)
        return line
    }
}

private extension FileHandle {
    func readFirstLine() -> Data? {
        let chunkSize = 4096
        seek(toFileOffset: 0)

        var data = readData(ofLength: chunkSize)
        var range = data.range(of: Data("\n".utf8))

        while range == nil && data.count > 0 {
            let newData = self.readData(ofLength: chunkSize)
            if newData.count == 0 {
                break
            }
            data.append(newData)
            range = data.range(of: Data("\n".utf8))
        }

        guard let range else {
            // No new-line character found, return all data
            return data
        }

        let lineData = data.subdata(in: 0..<range.upperBound)
        seek(toFileOffset: UInt64(lineData.count))

        return lineData
    }
}
