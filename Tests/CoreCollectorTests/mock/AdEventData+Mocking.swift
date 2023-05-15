@testable import CoreCollector
import Foundation

extension AdEventData {
    static var random: AdEventData {
        let adEventData = AdEventData()
        adEventData.time = Date().timeIntervalSince1970Millis
        adEventData.videoImpressionId = UUID().uuidString

        return adEventData
    }
}
