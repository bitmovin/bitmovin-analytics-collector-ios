import AmazonIVSPlayer
#if SWIFT_PACKAGE
import CoreCollector
#endif

class AmazonIVSPlayerContext: PlayerContext {
    private weak var player: IVSPlayer?

    init(player: IVSPlayer) {
        self.player = player
    }

    var position: CMTime? {
        player?.position
    }

    var isLive: Bool? {
        player?.duration.isIndefinite
    }
}
