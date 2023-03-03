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
        let playerContext = AmazonIVSPlayerContext(player: player)
        let videoStartupService = VideoStartupService(playerContext: playerContext,
                                                      stateMachine: stateMachine)
        let playerListener = AmazonIVSPlayerListener(player: player,
                                                     videoStartupService: videoStartupService,
                                                     stateMachine: stateMachine)

        return AmazonIVSPlayerAdapter(
            stateMachine: stateMachine,
            playerListener: playerListener,
            playerContext: playerContext
        )
    }
}
