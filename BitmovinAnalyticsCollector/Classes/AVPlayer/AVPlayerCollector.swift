import AVKit
import Foundation
#if SWIFT_PACKAGE
import BitmovinCollectorCore
#endif

@available(*, deprecated, message: "Please use new AVPlayerCollector and upgrade to v2.8.0")
public class AVPlayerCollector: Collector {
    public typealias TPlayer = AVPlayer

    private var analytics: BitmovinAnalyticsInternal

    @objc public init(config: BitmovinAnalyticsConfig) {
        self.analytics = BitmovinAnalyticsInternal.createAnalytics(config: config)
    }

    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    @objc public func attachPlayer(player: AVPlayer) {
        let adapter = AVPlayerAdapter(player: player, config: analytics.config, stateMachine: analytics.stateMachine)
        analytics.attach(adapter: adapter)
    }

    @objc public func detachPlayer() {
        analytics.detachPlayer()
    }

    @objc public func getCustomData() -> CustomData {
        return analytics.getCustomData()
    }

    @objc public func setCustomData(customData: CustomData) {
        return analytics.setCustomData(customData: customData)
    }

    @objc public func setCustomDataOnce(customData: CustomData) {
        return analytics.setCustomDataOnce(customData: customData)
    }
}
