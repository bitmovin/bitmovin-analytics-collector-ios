#if SWIFT_PACKAGE
import CoreCollector
#endif
import AmazonIVSPlayer

class PlayerInfoManipulator: EventDataManipulator {
    private let player: IVSPlayer
    internal init(player: IVSPlayer) {
        self.player = player
    }

    func manipulate(eventData: EventData) throws {
        eventData.version = player.version
    }
}
