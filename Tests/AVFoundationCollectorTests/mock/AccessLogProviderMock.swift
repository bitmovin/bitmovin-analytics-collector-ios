import Foundation
@testable import AVFoundationCollector
@testable import CoreCollector

class AccessLogProviderMock: AccessLogProvider {
    var events: [AccessLogDto]?

    func getEvents() -> [AccessLogDto]? {
        events
    }
}
