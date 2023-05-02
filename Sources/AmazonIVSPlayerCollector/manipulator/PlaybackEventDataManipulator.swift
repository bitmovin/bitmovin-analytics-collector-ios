#if SWIFT_PACKAGE
import CoreCollector
#endif
import AmazonIVSPlayer
import Foundation

class PlaybackEventDataManipulator: EventDataManipulator {
    private weak var player: IVSPlayerProtocol?
    private let config: BitmovinAnalyticsConfig

    init(
        player: IVSPlayerProtocol,
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
        eventData.videoDuration = getVideoDuration(player) ?? 0

        // IVS player only supports HLS, thus we hardcode it here
        eventData.streamFormat = StreamType.hls.rawValue
        eventData.m3u8Url = player.path?.absoluteString

        setLive(eventData, player)
    }

    private func getVideoDuration(_ player: IVSPlayerProtocol) -> Int64? {
        // if live stream return 0
        guard !player.duration.isIndefinite else {
            return 0
        }
        return player.duration.toMillis()
    }

    private func setLive(_ eventData: EventData, _ player: IVSPlayerProtocol) {
        guard player.duration.isValid else {
            return
        }
        eventData.isLive = player.duration.isIndefinite
    }
}
