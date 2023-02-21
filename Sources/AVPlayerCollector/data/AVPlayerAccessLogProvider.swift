import AVFoundation
import Foundation

class AVPlayerAccessLogProvider: AccessLogProvider {
    private var playerItem: AVPlayerItem

    init(playerItem: AVPlayerItem) {
        self.playerItem = playerItem
    }

    func getEvents() -> [AccessLogDto]? {
        guard let accessEvents = playerItem.accessLog()?.events else {
            return nil
        }

        var log: [AccessLogDto] = []

        for event in accessEvents {
            var logDto = toBitrateLogDto(event)
            logDto.index = accessEvents.lastIndex(of: event) ?? 0
            log.append(logDto)
        }
        return log
    }

    func toBitrateLogDto(_ accessLogEvent: AVPlayerItemAccessLogEvent) -> AccessLogDto {
        var log = AccessLogDto()
        log.indicatedBitrate = accessLogEvent.indicatedBitrate
        log.durationWatched = accessLogEvent.durationWatched
        log.numberOfMediaRequests = accessLogEvent.numberOfMediaRequests
        log.numberofBytesTransferred = accessLogEvent.numberOfBytesTransferred
        return log
    }
}
