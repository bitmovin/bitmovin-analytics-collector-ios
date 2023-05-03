import AVFoundation
import Foundation
import CoreCollector

class AVPlayerContext: PlayerContext {
    private weak var player: AVPlayer?
    private var playbackTypeDetectionService: PlaybackTypeDetectionService
    init(
        player: AVPlayer,
        playbackTypeDetectionService: PlaybackTypeDetectionService
    ) {
        self.player = player
        self.playbackTypeDetectionService = playbackTypeDetectionService
    }

    var position: CMTime? {
        player?.currentTime()
    }

    var isLive: Bool? {
        playbackTypeDetectionService.isLive()
    }

    var isPlaying: Bool {
        guard let player = self.player else {
            return false
        }
        return  player.rate > 0
    }
}
