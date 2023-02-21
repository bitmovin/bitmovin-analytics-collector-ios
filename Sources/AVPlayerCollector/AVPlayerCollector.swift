import AVKit
import Foundation
#if SWIFT_PACKAGE
import CoreCollector
#endif

@objc
@objcMembers
public class AVPlayerCollector: NSObject, Collector {
    public typealias TPlayer = AVPlayer

    private var analytics: BitmovinAnalyticsInternal
    private let stateMachine: StateMachine
    private let userIdProvider: UserIdProvider

    public init(config: BitmovinAnalyticsConfig) {
        self.stateMachine = StateMachine(config: config)
        self.userIdProvider = UserIdProviderFactory.create(randomizeUserId: config.randomizeUserId)
        self.analytics = BitmovinAnalyticsInternal.createAnalytics(
            config: config,
            stateMachine: stateMachine,
            userIdProvider: userIdProvider,
            manipulators: []
        )
    }

    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    public func attachPlayer(player: AVPlayer) {
        let adapter = buildAdapter(player: player)
        analytics.attach(adapter: adapter)
    }

    private func buildAdapter(player: AVPlayer) -> AVPlayerAdapter {
        AVPlayerAdapterFactory.createAdapter(
            stateMachine: self.stateMachine,
            player: player
        )
    }

    public func detachPlayer() {
        analytics.detachPlayer()
    }

    public func getCustomData() -> CustomData {
        analytics.getCustomData()
    }

    public func setCustomData(customData: CustomData) {
        analytics.setCustomData(customData: customData)
    }

    public func setCustomDataOnce(customData: CustomData) {
        analytics.setCustomDataOnce(customData: customData)
    }

    public func getUserId() -> String {
        self.userIdProvider.getUserId()
    }
}
