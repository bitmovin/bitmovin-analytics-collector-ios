#if SWIFT_PACKAGE
import CoreCollector
#endif
import AmazonIVSPlayer

class PlayerInfoManipulator: EventDataManipulator {
    private weak var player: IVSPlayer?
    internal init(player: IVSPlayer) {
        self.player = player
    }

    func manipulate(eventData: EventData) throws {
        guard let player = self.player else {
            return
        }

        eventData.version = player.version
    }
}
