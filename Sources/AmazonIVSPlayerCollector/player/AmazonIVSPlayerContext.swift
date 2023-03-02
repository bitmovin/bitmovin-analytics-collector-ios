import AmazonIVSPlayer
#if SWIFT_PACKAGE
import CoreCollector
#endif

class AmazonIVSPlayerContext: PlayerContext {
    private let player: IVSPlayer

    init(player: IVSPlayer) {
        self.player = player
    }

    var position: CMTime {
        player.position
    }
}
