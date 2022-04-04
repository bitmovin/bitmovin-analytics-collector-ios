import BitmovinPlayer
#if SWIFT_PACKAGE
import CoreCollector
#endif


public class BitmovinPlayerCollector : Collector {
    public typealias TPlayer = Player

    private var analytics: BitmovinAnalyticsInternal

    @objc public init(config: BitmovinAnalyticsConfig) {
        self.analytics = BitmovinAnalyticsInternal.createAnalytics(config: config)
    }
    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    @objc public func attachPlayer(player: Player) {
        let adapter = BitmovinPlayerAdapter(player: player, config: analytics.config, stateMachine: analytics.stateMachine)
        analytics.attach(adapter: adapter)

        if (analytics.adAnalytics != nil) {
            let adAdapter = BitmovinAdAdapter(bitmovinPlayer: player, adAnalytics: analytics.adAnalytics!)
            analytics.attachAd(adAdapter: adAdapter)
        }
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
