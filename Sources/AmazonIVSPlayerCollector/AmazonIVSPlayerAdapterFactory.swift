import AmazonIVSPlayer
import Foundation

#if SWIFT_PACKAGE
import CoreCollector
#endif

enum AmazonIVSPlayerAdapterFactory {
    static func createAdapter(
        player: IVSPlayer,
        analytics: BitmovinAnalyticsInternal,
        config: BitmovinAnalyticsConfig,
        manipulatorPipeline: EventDataManipulatorPipeline
    ) -> AmazonIVSPlayerAdapter {
        let playerContext = AmazonIVSPlayerContext(player: player)

        let stateMachine = StateMachineFactory.create(playerContext: playerContext)
        analytics.setStateMachine(stateMachine)

        let videoStartupService = DefaultVideoStartupService(
            playerContext: playerContext,
            stateMachine: stateMachine
        )

        let qualityProvider = DefaultPlaybackQualityProvider()
        let statisticsProvider = DefaultPlayerStatisticsProvider(player: player)

        let playbackService = DefaultPlaybackService(
            playerContext: playerContext,
            stateMachine: stateMachine,
            qualityProvider: qualityProvider,
            statisticsProvider: statisticsProvider
        )

        let errorService = DefaultErrorService(
            playerContext: playerContext,
            stateMachine: stateMachine
        )

        let playerListener = AmazonIVSPlayerListener(
            player: player,
            videoStartupService: videoStartupService,
            stateMachine: stateMachine,
            playbackService: playbackService,
            errorService: errorService
        )

        let playbackManipulator = PlaybackEventDataManipulator(
            player: player,
            config: config
        )
        manipulatorPipeline.registerEventDataManipulator(manipulator: playbackManipulator)

        let playerInfoManipulator = PlayerInfoManipulator(player: player)
        manipulatorPipeline.registerEventDataManipulator(manipulator: playerInfoManipulator)

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
