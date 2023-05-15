import Foundation

extension EventData: KeyDerivable {
    var derivedKey: LosslessStringConvertible? {
        EventDataKey(sessionId: impressionId, creationTime: creationTime)
    }

    var creationTime: TimeInterval {
        guard let eventDataCreationTime = time else {
            return .nan
        }

        return TimeInterval(eventDataCreationTime / 1_000)
    }
}
