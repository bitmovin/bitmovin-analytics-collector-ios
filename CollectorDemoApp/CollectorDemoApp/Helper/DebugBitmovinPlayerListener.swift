import BitmovinPlayerCore
import CoreCollector

class DebugBitmovinPlayerEvents: NSObject, PlayerListener, SourceListener {
    private let logger = _AnalyticsLogger(className: "DebugBitmovinPlayerEvents")

    func onEvent(_ event: Event, player: Player) {
        logger.d("onEvent PlayerListener: \(event.name)")
    }

    func onEvent(_ event: SourceEvent, source: Source) {
        logger.d("onEvent SourceListener: \(event.name) for source: \(source.sourceConfig.url)")
    }
}
