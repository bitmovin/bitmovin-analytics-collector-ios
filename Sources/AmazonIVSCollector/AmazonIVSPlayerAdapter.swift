import AmazonIVSPlayer
import CoreCollector
import Foundation

internal class AmazonIVSPlayerAdapter: CorePlayerAdapter, PlayerAdapter {
    private let playerListener: AmazonIVSPlayerListener
    private let playerContext: AmazonIVSPlayerContext
    private let statisticsProvider: PlayerStatisticsProvider
    private let qualityProvider: PlaybackQualityProvider

    init(
        stateMachine: StateMachine,
        playerListener: AmazonIVSPlayerListener,
        playerContext: AmazonIVSPlayerContext,
        statisticsProvider: PlayerStatisticsProvider,
        qualityProvider: PlaybackQualityProvider
    ) {
        self.playerContext = playerContext
        self.playerListener = playerListener
        self.statisticsProvider = statisticsProvider
        self.qualityProvider = qualityProvider
        super.init(stateMachine: stateMachine)
    }

    func initialize() {
        self.playerListener.startMonitoring()
    }

    func resetSourceState() {
        statisticsProvider.reset()
        qualityProvider.reset()
    }

    override func stopMonitoring() {
        self.playerListener.stopMonitoring()
    }

    var drmDownloadTime: Int64?

    var currentTime: CMTime? {
        self.playerContext.position
    }

    var currentSourceMetadata: SourceMetadata?
}
