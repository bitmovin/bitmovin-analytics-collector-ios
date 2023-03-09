import AmazonIVSPlayer
#if SWIFT_PACKAGE
import CoreCollector
#endif

class PlayerStatisticsProvider {
    private let player: IVSPlayerProtocol
    private var prevTotalDroppedFrames: Int = 0
    init(player: IVSPlayerProtocol) {
        self.player = player
    }

    func getDroppedFramesDelta() -> Int {
        let playerDroppedFrames = player.videoFramesDropped
        let currentDroppedFrames = playerDroppedFrames - prevTotalDroppedFrames
        self.prevTotalDroppedFrames = playerDroppedFrames
        return currentDroppedFrames
    }

    func reset() {
        prevTotalDroppedFrames = 0
    }
}
