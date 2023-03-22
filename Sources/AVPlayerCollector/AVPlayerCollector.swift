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
    private let userIdProvider: UserIdProvider
    private let eventDataFactory: EventDataFactory

    public init(config: BitmovinAnalyticsConfig) {
        self.userIdProvider = UserIdProviderFactory.create(randomizeUserId: config.randomizeUserId)
        self.eventDataFactory = EventDataFactory(config, userIdProvider)
        self.analytics = BitmovinAnalyticsInternal.createAnalytics(
            config: config,
            eventDataFactory: eventDataFactory
        )
    }

    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    public func attachPlayer(player: AVPlayer) {
        let adapter = AVPlayerAdapterFactory.createAdapter(
            analytics: analytics,
            eventDataFactory: eventDataFactory,
            player: player
        )
        analytics.attach(adapter: adapter)
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
