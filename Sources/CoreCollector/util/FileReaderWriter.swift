import Foundation

internal class FileReaderWriter {
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
