import Foundation

extension AdEventData: KeyDerivable {
    var derivedKey: LosslessStringConvertible? {
        guard let sessionId = videoImpressionId else { return nil }
        return EventDataKey(sessionId: sessionId, creationTime: creationTime)
    }

    var creationTime: TimeInterval {
        guard let eventDataCreationTime = time else {
            return .nan
        }

        return TimeInterval(eventDataCreationTime / 1_000)
    }
}
