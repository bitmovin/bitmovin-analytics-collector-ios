import Foundation
import AVFoundation

internal class BitrateDetectionService: NSObject {
    private static let heartbeatInterval: Double = 1.0
    
    @objc dynamic private(set) var videoBitrate: Double
    
    private let accessLogProvider: AccessLogProvider
    weak private var heartbeatTimer: Timer?
    
    init(accessLogProvider: AccessLogProvider) {
        self.accessLogProvider = accessLogProvider
        self.videoBitrate = 0
    }
    
    func startMonitoring() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(timeInterval: BitrateDetectionService.heartbeatInterval, target: self, selector: #selector(BitrateDetectionService.detectBitrateChange), userInfo: nil, repeats: true)
    }
    
    func stopMonitoring() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
    
    func resetSourceState() {
        videoBitrate = 0
    }
    
    @objc func detectBitrateChange() {
        guard let currentLogEntry = getCurrentLogEntry() else {
            return
        }
        
        if currentLogEntry.indicatedBitrate <= 0 {
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
    private func getCurrentLogEntry() -> AccessLogDto? {
        guard let events = accessLogProvider.getEvents() else {
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
