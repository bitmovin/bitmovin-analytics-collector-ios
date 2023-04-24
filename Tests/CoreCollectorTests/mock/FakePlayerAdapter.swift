import CoreMedia
@testable import CoreCollector

class FakePlayerAdapter: PlayerAdapter {
    func decorateEventData(eventData: EventData) {}

    func initialize() {}

    func stopMonitoring() {}

    func destroy() {}

    func resetSourceState() {}

    func resetEventDataState() {}

    var drmDownloadTime: Int64?

    var currentTime: CMTime?

    var currentSourceMetadata: SourceMetadata?
}
