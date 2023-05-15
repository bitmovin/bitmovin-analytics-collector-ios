import CoreCollector
import BitmovinPlayerCore

class BitmovinPlayerContext: PlayerContext {
    private weak var player: Player?

    init(player: Player) {
        self.player = player
    }

    var position: CMTime? {
        player?.currentTimeMillis
    }

    var isLive: Bool? {
        player?.isLive
    }

    var isPlaying: Bool {
        guard let player = self.player else {
            return false
        }
        return player.isPlaying
    }
}
