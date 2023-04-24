import Foundation
@testable import AVPlayerCollector
@testable import CoreCollector

class AccessLogProviderMock: AccessLogProvider {
    var events: [AccessLogDto]?

    func getEvents() -> [AccessLogDto]? {
        events
    }
}
