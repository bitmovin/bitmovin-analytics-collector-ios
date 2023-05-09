import Foundation

internal struct EventDataKey: LosslessStringConvertible {
    private let separator = "#"
    let sessionId: String
    let creationTime: TimeInterval
    var description: String {
        let keyString = String(creationTime) + separator + sessionId
        return Data(keyString.utf8).base64EncodedString()
    }

    init(sessionId: String, creationTime: TimeInterval) {
        self.sessionId = sessionId
        self.creationTime = creationTime
    }

    init?(_ description: String) {
        guard let data = Data(base64Encoded: description) else { return nil }
        guard let keyString = String(data: data, encoding: .utf8) else { return nil }
        guard let range = keyString.range(of: separator), !range.isEmpty else { return nil }

        let creationTimeString = String(keyString[..<range.lowerBound])
        let sessionId = String(keyString[range.upperBound...])

        guard let creationTime = TimeInterval(creationTimeString) else {
            return nil
        }

        self.sessionId = sessionId
        self.creationTime = creationTime
    }
}
