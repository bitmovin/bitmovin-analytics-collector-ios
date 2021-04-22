import BitmovinPlayer

public class BitmovinPlayerCollector : BitmovinAnalyticsInternal {
    private var sourceMetadataProvider = SourceMetadataProvider<Source>()
    
    @objc public override init(config: BitmovinAnalyticsConfig) {
        super.init(config: config);
    }
    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    @objc public func attachPlayer(player: Player) {
        attach(adapter: BitmovinPlayerAdapter(player: player, config: config, stateMachine: stateMachine, sourceMetadataProvider: sourceMetadataProvider))
        if (self.adAnalytics != nil) {
            attachAd(adAdapter: BitmovinAdAdapter(bitmovinPlayer: player, adAnalytics: self.adAnalytics!))
        }
    }
    
    @objc public func addSourceMetadata(playerSource: Source, sourceMetadata: SourceMetadata) {
        sourceMetadataProvider.add(source: playerSource, sourceMetadata: sourceMetadata)
    }
}
