import AmazonIVSPlayer
import Foundation

#if SWIFT_PACKAGE
import CoreCollector
#endif

enum AmazonIVSPlayerAdapterFactory {
    static func createAdapter(
        player: IVSPlayer,
        stateMachine: StateMachine
    ) -> AmazonIVSPlayerAdapter {
        let playerListener = AmazonIVSPlayerListener(player: player)
        let playerContext = AmazonIVSPlayerContext(player: player)

        return AmazonIVSPlayerAdapter(
            stateMachine: stateMachine,
            playerListener: playerListener,
            playerContext: playerContext
        )
    }
}
