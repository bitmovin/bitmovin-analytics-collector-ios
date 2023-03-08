import AmazonIVSPlayer
#if SWIFT_PACKAGE
import CoreCollector
#endif
import Foundation

internal class AmazonIVSPlayerAdapter: CorePlayerAdapter, PlayerAdapter {
    private let playerListener: AmazonIVSPlayerListener
    private let playerContext: AmazonIVSPlayerContext

    init(
        stateMachine: StateMachine,
        playerListener: AmazonIVSPlayerListener,
        playerContext: AmazonIVSPlayerContext
    ) {
        self.playerContext = playerContext
        self.playerListener = playerListener
        super.init(stateMachine: stateMachine)
    }

    func initialize() {
        self.playerListener.startMonitoring()
    }

    func resetSourceState() {
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
