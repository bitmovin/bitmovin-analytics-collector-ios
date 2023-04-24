import Foundation



#if SWIFT_PACKAGE
@testable import AVPlayerCollector
@testable import CoreCollector
#endif

class AccessLogProviderMock: AccessLogProvider {
    var events: [AccessLogDto]?

    func getEvents() -> [AccessLogDto]? {
        events
    }
}
