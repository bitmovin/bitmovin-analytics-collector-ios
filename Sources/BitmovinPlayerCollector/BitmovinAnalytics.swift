import BitmovinPlayerCore
#if SWIFT_PACKAGE
import CoreCollector
#endif

public class BitmovinAnalytics: BitmovinPlayerCollector {
    override public init(config: BitmovinAnalyticsConfig) {
        super.init(config: config)
    }

    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    @objc
    public func attachBitmovinPlayer(player: Player) {
        super.attachPlayer(player: player)
    }
}
