import Foundation

public protocol EventDataDispatcher {
    func add(_ eventData: EventData)
    func addAd(_ adEventData: AdEventData)
    func disable()
    func resetSourceState()
}
