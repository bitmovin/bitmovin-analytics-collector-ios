#if SWIFT_PACKAGE
import CoreCollector
#endif
import AmazonIVSPlayer

class PlayerInfoManipulator: EventDataManipulator {
    private let playerTech = "ios:amazonivs"

    private weak var player: IVSPlayerProtocol?

    internal init(player: IVSPlayerProtocol) {
        self.player = player
    }

    func manipulate(eventData: EventData) {
        guard let player = self.player else {
            return
        }

        eventData.version = PlayerType.amazonivs.rawValue + "-" + player.version
        eventData.player = PlayerType.amazonivs.rawValue
        eventData.playerTech = playerTech
    }
}
