import Foundation

private let separator: Character = "#"

internal struct EventDataKey: LosslessStringConvertible {
    let sessionId: String
    let creationTime: TimeInterval
    var description: String {
        let keyString = String(creationTime) + String(separator) + sessionId
        return Data(keyString.utf8).base64EncodedString()
    }

    init(sessionId: String, creationTime: TimeInterval) {
        self.sessionId = sessionId
        self.creationTime = creationTime
    }

    init?(_ description: String) {
        guard let data = Data(base64Encoded: description),
              let keyString = String(data: data, encoding: .utf8) else {
            return nil
        }

        let components = keyString.split(separator: separator, maxSplits: 1, omittingEmptySubsequences: false)
        guard components.count == 2 else {
            return nil
        }

        let creationTimeString = String(components[0])
        let sessionId = String(components[1])

        guard let creationTime = TimeInterval(creationTimeString) else {
            return nil
        }

        self.sessionId = sessionId
        self.creationTime = creationTime
    }
}
