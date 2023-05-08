import Foundation

private let lineSeparator = Data("\n".utf8)
private let chunkSize = 4096

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

        if line.suffix(lineSeparator.count) != lineSeparator {
            var line = line
            line.append(lineSeparator)
        }

        fileHandle.write(line)
    }

    func readFirstLine(from file: URL) -> Data? {
        guard let fileHandle = try? FileHandle(forReadingFrom: file) else { return nil }
        defer {
            fileHandle.closeFile()
        }

        guard let line = fileHandle.readLine(lineSeparator, chunkSize) else {
            return nil
        }

        return line
    }

    func removeFirstLine(from file: URL) -> Data? {
        guard let fileHandle = try? FileHandle(forUpdating: file) else { return nil }
        guard let line = fileHandle.readLine(lineSeparator, chunkSize) else {
            fileHandle.closeFile()
            return nil
        }

        let remainingData = fileHandle.readDataToEndOfFile()
        fileHandle.closeFile()

        try? remainingData.write(to: file, options: .atomic)
        return line
    }

    func numberOfLines(in file: URL) -> Int {
        guard let fileHandle = try? FileHandle(forReadingFrom: file) else { return 0 }
        defer {
            fileHandle.closeFile()
        }

        var numberOfLines = 0
        while fileHandle.readLine(lineSeparator, chunkSize) != nil {
            numberOfLines += 1
        }

        return numberOfLines
    }
}

private extension FileHandle {
    func readLine(_ lineSeparator: Data, _ chunkSize: Int) -> Data? {
        let initialOffset = offsetInFile
        var data = readData(ofLength: chunkSize)
        var range = data.range(of: lineSeparator)

        while range == nil && !data.isEmpty {
            let newData = readData(ofLength: chunkSize)
            if newData.isEmpty {
                break
            }
            data.append(newData)
            range = data.range(of: lineSeparator)
        }

        guard let range else {
            seekToEndOfFile()
            return !data.isEmpty ? data : nil
        }

        let lineData = data.subdata(in: 0..<range.upperBound)
        seek(toFileOffset: initialOffset + UInt64(lineData.count))

        return lineData
    }
}
