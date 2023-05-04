import BitmovinPlayer
import CoreCollector

@objc
public class BitmovinPlayerCollector: NSObject, Collector {
    public typealias TPlayer = Player

    private var sourceMetadataProvider = SourceMetadataProvider<Source>()
    private var analytics: BitmovinAnalyticsInternal
    private var config: BitmovinAnalyticsConfig
    private let userIdProvider: UserIdProvider
    private let eventDataFactory: EventDataFactory

    @objc
    public init(config: BitmovinAnalyticsConfig) {
        self.userIdProvider = UserIdProviderFactory.create(randomizeUserId: config.randomizeUserId)
        self.eventDataFactory = EventDataFactory(config, userIdProvider)
        self.analytics = BitmovinAnalyticsInternal.createAnalytics(
            config: config,
            eventDataFactory: eventDataFactory
        )
        self.config = config
    }
    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    @objc
    public func attachPlayer(player: Player) {
        let castManipulator = CastEventDataManipulator(player: player)
        eventDataFactory.registerEventDataManipulator(manipulator: castManipulator)

        let playerContext = BitmovinPlayerContext(player: player)
        let stateMachine = StateMachineFactory.create(playerContext: playerContext)
        analytics.setStateMachine(stateMachine)
        let adapter = BitmovinPlayerAdapter(
            player: player,
            config: self.config,
            stateMachine: stateMachine,
            sourceMetadataProvider: sourceMetadataProvider
        )
        eventDataFactory.registerEventDataManipulator(manipulator: adapter)
        analytics.attach(adapter: adapter)
        if let adAnalytics = analytics.adAnalytics {
            let adAdapter = BitmovinAdAdapter(bitmovinPlayer: player, adAnalytics: adAnalytics)
            analytics.attachAd(adAdapter: adAdapter)
        }
    }

    @objc
    public func detachPlayer() {
        analytics.detachPlayer()
    }

    @objc
    public func getCustomData() -> CustomData {
        analytics.getCustomData()
    }

    @objc
    public func setCustomData(customData: CustomData) {
        analytics.setCustomData(customData: customData)
    }

    @objc
    public func setCustomDataOnce(customData: CustomData) {
        analytics.setCustomDataOnce(customData: customData)
    }

    @objc
    public func addSourceMetadata(playerSource: Source, sourceMetadata: SourceMetadata) {
        sourceMetadataProvider.add(source: playerSource, sourceMetadata: sourceMetadata)
    }

    @objc
    public func getUserId() -> String {
        self.userIdProvider.getUserId()
    }
}
