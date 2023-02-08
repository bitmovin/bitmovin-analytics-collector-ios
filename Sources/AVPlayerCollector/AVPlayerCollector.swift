import AVKit
import Foundation
#if SWIFT_PACKAGE
import CoreCollector
#endif

@objc
public class AVPlayerCollector: NSObject, Collector {
    public typealias TPlayer = AVPlayer

    private var analytics: BitmovinAnalyticsInternal
    private let factory: AVPlayerAdapterFactory = AVPlayerAdapterFactory()

    @objc public init(config: BitmovinAnalyticsConfig) {
        self.analytics = BitmovinAnalyticsInternal.createAnalytics(config: config)
    }

    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    @objc public func attachPlayer(player: AVPlayer) {
        let adapter = buildAdapter(player: player)
        analytics.attach(adapter: adapter)
    }
    
    private func buildAdapter(player: AVPlayer) -> AVPlayerAdapter {
        return factory.createAdapter(stateMachine: analytics.stateMachine, player: player)
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
    
    @objc public func getUserId() -> String {
        return analytics.getUserId()
    }
}
