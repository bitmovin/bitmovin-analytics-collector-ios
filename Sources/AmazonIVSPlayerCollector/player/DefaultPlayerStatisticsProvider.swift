import AmazonIVSPlayer
import CoreCollector

class DefaultPlayerStatisticsProvider: PlayerStatisticsProvider {
    private weak var player: IVSPlayerProtocol?
    private var prevTotalDroppedFrames: Int = 0

    init(player: IVSPlayerProtocol) {
        self.player = player
    }

    func getDroppedFramesDelta() -> Int {
        guard let player = self.player else {
            return 0
        }

        let playerDroppedFrames = player.videoFramesDropped
        let currentDroppedFrames = playerDroppedFrames - prevTotalDroppedFrames
        self.prevTotalDroppedFrames = playerDroppedFrames
        return currentDroppedFrames
    }

    func reset() {
        prevTotalDroppedFrames = 0
    }
}
