import BitmovinPlayer
#if SWIFT_PACKAGE
import BitmovinCollectorCore
#endif

public class BitmovinPlayerCollector : Collector {
    public typealias TPlayer = Player
    
    private var sourceMetadataProvider = SourceMetadataProvider<Source>()
    private var analytics: BitmovinAnalyticsInternal
    
    @objc public init(config: BitmovinAnalyticsConfig) {
        self.analytics = BitmovinPlayerCollector.createAnalytics(config: config)
    }
    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    @objc public func attachPlayer(player: Player) {
        let adapter = BitmovinPlayerAdapter(player: player, config: analytics.config, stateMachine: analytics.stateMachine, sourceMetadataProvider: sourceMetadataProvider)
        analytics.attach(adapter: adapter)
        if (analytics.adAnalytics != nil) {
            analytics.attachAd(adAdapter: BitmovinAdAdapter(bitmovinPlayer: player, adAnalytics: analytics.adAnalytics!))
        }
    }
    
    @objc public func addSourceMetadata(playerSource: Source, sourceMetadata: SourceMetadata) {
        sourceMetadataProvider.add(source: playerSource, sourceMetadata: sourceMetadata)
    }
}
