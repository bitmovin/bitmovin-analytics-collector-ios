import Foundation
import AVFoundation

class PlaybackTypeDetectionService {
    
    private(set) var playbackType: String? = nil
    
    private let player: AVPlayer
    
    init(player: AVPlayer) {
        self.player = player
    }
    
    func startMonitoring(playerItem: AVPlayerItem) {
        NotificationCenter.default.addObserver(self, selector: #selector(observeNewAccessLogEntry(notification:)), name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: playerItem)
    }
    
    func stopMonitoring(playerItem: AVPlayerItem) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: playerItem)
        resetSourceState()
    }
    
    func resetSourceState() {
        playbackType = nil
    }
    
    func isLive() -> Bool {
        switch(playbackType?.uppercased()) {
        case "VOD":
            return false
        case "FILE":
            return false
        case "LIVE":
            return true
        default:
            return false
        }
    }
    
    @objc private func observeNewAccessLogEntry(notification: NSNotification) {
        guard let playerItem = notification.object as? AVPlayerItem, let events = playerItem.accessLog()?.events else {
            return
        }
        
        let event = events.first() { event in event.playbackType != nil }
        guard let playbackType = event?.playbackType else {
            return
        }
        
        self.playbackType = playbackType
        
        // we only need to get to this point once so we stop monitoring on that event
        stopMonitoring(playerItem: playerItem)
    }
}
