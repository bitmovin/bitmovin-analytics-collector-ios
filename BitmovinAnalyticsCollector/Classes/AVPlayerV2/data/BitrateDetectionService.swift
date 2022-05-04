import Foundation
import AVFoundation

internal class BitrateDetectionService: NSObject {
    
    @objc dynamic var videoBitrate: Double
    
    private let player: AVPlayer
    
    init(player: AVPlayer) {
        self.player = player
        self.videoBitrate = 0
    }
    
    func startMonitoring() {
        // TODO create Timer
    }
    
    func stopMonitoring() {
        // TODO kill timer
    }
    
    private func detectBitrateChange() {
        guard let currentLogEntry = getCurrentLogEntry() else {
            return
        }
        
        if currentLogEntry.indicatedBitrate == videoBitrate {
            return
        }
        
        // This will trigger outside key-value-observation (KVO)
        videoBitrate = currentLogEntry.indicatedBitrate
    }
    
    /*
     returns the last AccessLogEntry with durationWatched > 0
     for us this is the current relevant entry
     */
    private func getCurrentLogEntry() -> AVPlayerItemAccessLogEvent? {
        guard let events = player.currentItem?.accessLog()?.events else {
            return nil
        }
        
        if events.isEmpty {
            return nil
        }
        
        let index = events.lastIndex() { event in
            event.durationWatched > 0
        }
        
        if index == nil {
            return nil
        }
        
        return events[index!]
    }
}
