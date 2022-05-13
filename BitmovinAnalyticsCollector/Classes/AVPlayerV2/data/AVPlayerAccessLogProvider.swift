import Foundation
import AVFoundation

class AVPlayerAccessLogProvider: AccessLogProvider {
    private let player: AVPlayer
    
    init(player: AVPlayer) {
        self.player = player
    }
    
    func getEvents() -> [AccessLogDto]? {
        guard let accessEvents = player.currentItem?.accessLog()?.events else {
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
        log.numberofBytesTransfered = accessLogEvent.numberOfBytesTransferred
        return log
    }
}
