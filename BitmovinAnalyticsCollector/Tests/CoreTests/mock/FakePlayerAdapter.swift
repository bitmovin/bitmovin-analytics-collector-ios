import CoreMedia
#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

#if SWIFT_PACKAGE
@testable import BitmovinCollectorCore
#endif

class FakePlayerAdapter: PlayerAdapter {
    func decorateEventData(eventData: EventData) {
        
    }
    
    func initialize() {
        
    }
    
    func stopMonitoring() {
        
    }
    
    func destroy() {
        
    }
    
    func resetSourceState() {
        
    }
    
    var drmDownloadTime: Int64?
    
    var currentTime: CMTime?
    
    var currentSourceMetadata: SourceMetadata?
}
