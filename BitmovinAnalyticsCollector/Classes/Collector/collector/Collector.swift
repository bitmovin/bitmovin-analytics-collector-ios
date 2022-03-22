import Foundation

public protocol Collector {
    associatedtype TPlayer
    func attachPlayer(player: TPlayer)
}

extension Collector {
    static public func createAnalytics(config: BitmovinAnalyticsConfig) -> BitmovinAnalyticsInternal {
        return BitmovinAnalyticsInternal(config: config)
    }
}
