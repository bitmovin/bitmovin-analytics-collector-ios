#if SWIFT_PACKAGE
import CoreCollector
#endif
import AmazonIVSPlayer
import Foundation

class PlaybackEventDataManipulator: EventDataManipulator {
    private weak var player: IVSPlayer?
    private let config: BitmovinAnalyticsConfig

    init(
        player: IVSPlayer,
        config: BitmovinAnalyticsConfig
    ) {
        self.player = player
        self.config = config
    }

    func manipulate(eventData: EventData) throws {
        guard let player = self.player else {
            return
        }

        eventData.isMuted = player.muted
        eventData.videoDuration = player.duration.toMillis() ?? 0

        // IVS player only supports HLS, thus we hardcode it here
        eventData.streamFormat = StreamType.hls.rawValue
        eventData.m3u8Url = player.path?.absoluteString

        setLive(eventData, player)
    }

    private func setLive(_ eventData: EventData, _ player: IVSPlayer) {
        let isLiveConfig = config.isLive
        if isLiveConfig {
            eventData.isLive = isLiveConfig
        } else {
            eventData.isLive = player.duration.isIndefinite
        }
    }
}
