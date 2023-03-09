import AmazonIVSPlayer
import Foundation

#if SWIFT_PACKAGE
import CoreCollector
#endif

enum AmazonIVSPlayerAdapterFactory {
    static func createAdapter(
        player: IVSPlayer,
        stateMachine: StateMachine,
        config: BitmovinAnalyticsConfig,
        manipulatorPipeline: EventDataManipulatorPipeline
    ) -> AmazonIVSPlayerAdapter {
        let playerContext = AmazonIVSPlayerContext(player: player)
        let videoStartupService = VideoStartupService(
            playerContext: playerContext,
            stateMachine: stateMachine
        )

        let qualityProvider = PlaybackQualityProvider()

        let playbackService = PlaybackService(
            playerContext: playerContext,
            stateMachine: stateMachine
        )
        let playerListener = AmazonIVSPlayerListener(
            player: player,
            videoStartupService: videoStartupService,
            stateMachine: stateMachine,
            playbackService: playbackService,
            qualityProvider: qualityProvider
        )

        let playbackManipulator = PlaybackEventDataManipulator(
            player: player,
            config: config
        )
        manipulatorPipeline.registerEventDataManipulator(manipulator: playbackManipulator)

        let playerInfoManipulator = PlayerInfoManipulator(player: player)
        manipulatorPipeline.registerEventDataManipulator(manipulator: playerInfoManipulator)

        let statisticsProvider = PlayerStatisticsProvider(player: player)
        let qualityManipulator = QualityEventDataManipulator(
            statisticsProvider: statisticsProvider,
            qualityProvider: qualityProvider
        )
        manipulatorPipeline.registerEventDataManipulator(manipulator: qualityManipulator)

        return AmazonIVSPlayerAdapter(
            stateMachine: stateMachine,
            playerListener: playerListener,
            playerContext: playerContext,
            statisticsProvider: statisticsProvider,
            qualityProvider: qualityProvider
        )
    }
}
