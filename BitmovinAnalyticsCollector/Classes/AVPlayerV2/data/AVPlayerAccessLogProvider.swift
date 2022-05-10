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
        
        let log: [AccessLogDto]? = []
        
        for event in accessEvents {
            let logDto = toBitrateLogDto(event)
            logDto.index = accessEvents.lastIndex(of: event) ?? 0
        }
        return log
    }
    
    func toBitrateLogDto(_ accessLogEvent: AVPlayerItemAccessLogEvent) -> AccessLogDto {
        let log = AccessLogDto()
        log.indicatedBitrate = accessLogEvent.indicatedBitrate
        log.durationWatched = accessLogEvent.durationWatched
        log.numberOfMediaRequests = accessLogEvent.numberOfMediaRequests
        log.numberofBytesTransfered = accessLogEvent.numberOfBytesTransferred
        return log
    }
}
