// TODO: Maybe remove, does not seem that we need it
internal class PersistentAdEventData: Codable, Equatable {
    let adEventData: AdEventData
    var retryCount: Int = 0

    init(adEventData: AdEventData) {
        self.adEventData = adEventData
    }

    static func == (lhs: PersistentAdEventData, rhs: PersistentAdEventData) -> Bool {
        lhs.adEventData == rhs.adEventData
    }
}
