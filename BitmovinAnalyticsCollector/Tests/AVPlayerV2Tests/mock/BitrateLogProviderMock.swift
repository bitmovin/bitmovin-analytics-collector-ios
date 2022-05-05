import Foundation

#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

#if SWIFT_PACKAGE
@testable import AVPlayerCollector
@testable import CoreCollector
#endif

class BitrateLogProviderMock: BitrateLogProvider {
    var events: [BitrateLogDto]? = nil
    
    func getEvents() -> [BitrateLogDto]? {
        return events
    }
}

