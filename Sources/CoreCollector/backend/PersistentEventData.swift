internal class PersistentEventData: Codable, Equatable {
    let eventData: EventData
    var retryCount: Int = 0

    init(eventData: EventData) {
        self.eventData = eventData
    }

    static func == (lhs: PersistentEventData, rhs: PersistentEventData) -> Bool {
        lhs.eventData == rhs.eventData
    }
}
