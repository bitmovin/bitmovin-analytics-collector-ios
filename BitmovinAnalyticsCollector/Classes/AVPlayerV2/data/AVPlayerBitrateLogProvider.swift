//
//  AVPlayerBitrateLogProvider.swift
//  Pods
//
//  Created by Thomas Sabe on 05.05.22.
//

import Foundation
import AVFoundation

class AVPlayerBitrateLogProvider: BitrateLogProvider {
    private let player: AVPlayer
    
    init(player: AVPlayer) {
        self.player = player
    }
    
    func getEvents() -> [BitrateLogDto]? {
        guard let accessEvents = player.currentItem?.accessLog()?.events else {
            return nil
        }
            
        return accessEvents.map(toBitrateLogDto)
    }
    
    func toBitrateLogDto(_ accessLogEvent: AVPlayerItemAccessLogEvent) -> BitrateLogDto {
        let log = BitrateLogDto()
        log.indicatedBitrate = accessLogEvent.indicatedBitrate
        log.durationWatched = accessLogEvent.durationWatched
        return log
    }
}
