import AmazonIVSPlayer
import CoreCollector

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

    var isPlaying: Bool {
        player != nil && player?.state == IVSPlayer.State.playing
    }
}
