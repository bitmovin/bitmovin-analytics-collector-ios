@testable import CoreCollector
import Foundation

extension EventData {
    static var random: EventData {
        let eventData = EventData(UUID().uuidString)
        eventData.audioBitrate = 3_000
        eventData.videoCodec = "hevc"
        eventData.audioLanguage = "de"
        eventData.videoTitle = "Art of Motion"
        eventData.cdnProvider = "Akamai"
        eventData.domain = "com.bitmovin.player"
        eventData.time = Date().timeIntervalSince1970Millis

        return eventData
    }

    static var old: EventData {
        let eventData = EventData.random
        eventData.time = 0

        return eventData
    }
}
