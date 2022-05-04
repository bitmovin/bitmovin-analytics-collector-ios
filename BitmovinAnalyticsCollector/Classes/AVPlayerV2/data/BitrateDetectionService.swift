import Foundation
import AVFoundation

internal class BitrateDetectionService: NSObject {
    
    @objc dynamic var videoBitrate:  Double
    
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
        // TODO do fancy stuff with accessLog and magically pull bitrate out :D
        
        // This will trigger outside key-value-observation (KVO)
        videoBitrate = 123 // put here new bitrate
    }
    
}
