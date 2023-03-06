import AmazonIVSPlayer
#if SWIFT_PACKAGE
import CoreCollector
#endif

@objc
public class AmazonIVSCollector: NSObject, Collector {
    public typealias TPlayer = IVSPlayer
    private var analytics: BitmovinAnalyticsInternal
    private let stateMachine: StateMachine
    private let userIdProvider: UserIdProvider
    private let eventDataFactory: EventDataFactory

    public init(config: BitmovinAnalyticsConfig) {
        self.userIdProvider = UserIdProviderFactory.create(randomizeUserId: config.randomizeUserId)
        self.eventDataFactory = EventDataFactory(config, userIdProvider)
        self.analytics = BitmovinAnalyticsInternal.createAnalytics(
            config: config,
            eventDataFactory: eventDataFactory
        )
        self.stateMachine = self.analytics.getStateMachine()
    }

    public func attachPlayer(player: IVSPlayer) {
        let adapter = AmazonIVSPlayerAdapterFactory.createAdapter(
            player: player,
            stateMachine: self.stateMachine
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
